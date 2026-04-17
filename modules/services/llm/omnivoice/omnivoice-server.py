# Hot daemon: loads libomnivoice once via ctypes, keeps ov_context alive
# across requests. Each POST /tts only triggers ov_synthesize.
import array
import ctypes
import io
import json
import logging
import os
import re
import struct
import subprocess
import sys
import threading
import urllib.parse
import wave
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stderr,
)
log = logging.getLogger("omnivoice")

LIB_PATH = os.environ["OMNIVOICE_LIB"]
CODEC_BIN = os.environ["OMNIVOICE_CODEC_BIN"]
MODEL = os.environ["OMNIVOICE_MODEL"]
CODEC = os.environ["OMNIVOICE_CODEC"]
LISTEN_HOST = os.environ.get("LISTEN_HOST", "127.0.0.1")
LISTEN_PORT = int(os.environ.get("LISTEN_PORT", "11436"))
DEFAULT_LANG = os.environ.get("DEFAULT_LANG", "English")
DEFAULT_INSTRUCT = os.environ.get("DEFAULT_INSTRUCT", "")
DEFAULT_STEPS = int(os.environ.get("DEFAULT_STEPS", "16"))
VOICE_WAV = os.environ.get("VOICE_WAV") or None
VOICE_TEXT = os.environ.get("VOICE_TEXT") or None

OV_ABI_VERSION = 2


REF_K = 8  # OmniVoice tokenizer is fixed at 8 codebooks (HuBERT + RVQ).


def unpack_rvq(data, k=REF_K):
    """Unpack 11-bit-per-code LSB-first byte stream into a flat int32 list."""
    codes = []
    acc = 0
    bits = 0
    for byte in data:
        acc |= byte << bits
        bits += 8
        while bits >= 11:
            codes.append(acc & 0x7FF)
            acc >>= 11
            bits -= 11
    return codes


def encode_reference(wav_path, codec_gguf):
    """Run omnivoice-codec to pre-encode the reference WAV, return int32 codes (flat [K, T])."""
    rvq_path = os.path.splitext(wav_path)[0] + ".rvq"
    if not os.path.exists(rvq_path) or os.path.getmtime(rvq_path) < os.path.getmtime(wav_path):
        log.info("pre-encoding reference: %s -> %s", wav_path, rvq_path)
        r = subprocess.run(
            [CODEC_BIN, "--model", codec_gguf, "-i", wav_path],
            capture_output=True,
            check=False,
        )
        if r.returncode != 0:
            raise SystemExit("omnivoice-codec failed:\n" + r.stderr.decode("utf-8", "replace"))
    with open(rvq_path, "rb") as f:
        raw = f.read()
    codes = unpack_rvq(raw)
    t = len(codes) // REF_K
    # Trim any trailing partial frame.
    codes = codes[: REF_K * t]
    return codes, t


class OvAudio(ctypes.Structure):
    _fields_ = [
        ("samples", ctypes.POINTER(ctypes.c_float)),
        ("n_samples", ctypes.c_int),
        ("sample_rate", ctypes.c_int),
        ("channels", ctypes.c_int),
    ]


class OvInitParams(ctypes.Structure):
    _fields_ = [
        ("abi_version", ctypes.c_int),
        ("model_path", ctypes.c_char_p),
        ("codec_path", ctypes.c_char_p),
        ("use_fa", ctypes.c_bool),
        ("clamp_fp16", ctypes.c_bool),
    ]


class OvTtsParams(ctypes.Structure):
    _fields_ = [
        ("abi_version", ctypes.c_int),
        ("text", ctypes.c_char_p),
        ("lang", ctypes.c_char_p),
        ("instruct", ctypes.c_char_p),
        ("T_override", ctypes.c_int),
        ("chunk_duration_sec", ctypes.c_float),
        ("chunk_threshold_sec", ctypes.c_float),
        ("denoise", ctypes.c_bool),
        ("preprocess_prompt", ctypes.c_bool),
        ("mg_num_step", ctypes.c_int),
        ("mg_guidance_scale", ctypes.c_float),
        ("mg_t_shift", ctypes.c_float),
        ("mg_layer_penalty_factor", ctypes.c_float),
        ("mg_position_temperature", ctypes.c_float),
        ("mg_class_temperature", ctypes.c_float),
        ("mg_seed", ctypes.c_uint64),
        ("ref_audio_tokens", ctypes.c_void_p),
        ("ref_T", ctypes.c_int),
        ("ref_audio_24k", ctypes.c_void_p),
        ("ref_n_samples", ctypes.c_int),
        ("ref_text", ctypes.c_char_p),
        ("dump_dir", ctypes.c_char_p),
        ("cancel", ctypes.c_void_p),
        ("cancel_user_data", ctypes.c_void_p),
        ("on_chunk", ctypes.c_void_p),
        ("on_chunk_user_data", ctypes.c_void_p),
    ]


lib = ctypes.CDLL(LIB_PATH)

lib.ov_version.restype = ctypes.c_char_p
lib.ov_last_error.restype = ctypes.c_char_p
lib.ov_init_default_params.argtypes = [ctypes.POINTER(OvInitParams)]
lib.ov_init.argtypes = [ctypes.POINTER(OvInitParams)]
lib.ov_init.restype = ctypes.c_void_p
lib.ov_free.argtypes = [ctypes.c_void_p]
lib.ov_tts_default_params.argtypes = [ctypes.POINTER(OvTtsParams)]
lib.ov_synthesize.argtypes = [
    ctypes.c_void_p,
    ctypes.POINTER(OvTtsParams),
    ctypes.POINTER(OvAudio),
]
lib.ov_synthesize.restype = ctypes.c_int
lib.ov_audio_free.argtypes = [ctypes.POINTER(OvAudio)]

# bool (*)(const float * samples, int n_samples, void * user_data)
OV_AUDIO_CHUNK_CB = ctypes.CFUNCTYPE(
    ctypes.c_bool,
    ctypes.POINTER(ctypes.c_float),
    ctypes.c_int,
    ctypes.c_void_p,
)


def write_streaming_wav_header(out, sample_rate):
    """44-byte WAV header with 0xFFFFFFFE sizes — players read until EOF."""
    UNK = 0xFFFFFFFE
    out.write(b"RIFF")
    out.write(struct.pack("<I", UNK))
    out.write(b"WAVE")
    out.write(b"fmt ")
    out.write(struct.pack("<I", 16))            # Subchunk1Size (PCM)
    out.write(struct.pack("<H", 1))             # AudioFormat = PCM
    out.write(struct.pack("<H", 1))             # NumChannels
    out.write(struct.pack("<I", sample_rate))   # SampleRate
    out.write(struct.pack("<I", sample_rate * 2))  # ByteRate
    out.write(struct.pack("<H", 2))             # BlockAlign
    out.write(struct.pack("<H", 16))            # BitsPerSample
    out.write(b"data")
    out.write(struct.pack("<I", UNK))


def floats_to_pcm16(samples_ptr, n):
    buf = bytearray(n * 2)
    for i in range(n):
        s = samples_ptr[i]
        if s > 1.0:
            s = 1.0
        elif s < -1.0:
            s = -1.0
        struct.pack_into("<h", buf, i * 2, int(s * 32767.0))
    return bytes(buf)

log.info("libomnivoice version: %s", lib.ov_version().decode())

iparams = OvInitParams()
lib.ov_init_default_params(ctypes.byref(iparams))
iparams.abi_version = OV_ABI_VERSION
iparams.model_path = MODEL.encode()
iparams.codec_path = CODEC.encode()
ctx = lib.ov_init(ctypes.byref(iparams))
if not ctx:
    err = lib.ov_last_error()
    raise SystemExit(f"ov_init failed: {err.decode() if err else 'unknown'}")
log.info("ov_context ready")

# Voice cloning: pre-encode reference once at startup so the HuBERT
# silence-trim + encode step doesn't repeat per request.
REF_TOKENS = None
REF_T = 0
REF_TEXT_B = None
if VOICE_WAV and VOICE_TEXT:
    codes, REF_T = encode_reference(VOICE_WAV, CODEC)
    REF_TOKENS = (ctypes.c_int32 * len(codes))(*codes)
    REF_TEXT_B = VOICE_TEXT.encode("utf-8")
    log.info("reference voice ready: K=%d T=%d (%.2fs at 50 codes/s ~)",
             REF_K, REF_T, REF_T / 50.0)
elif VOICE_WAV or VOICE_TEXT:
    raise SystemExit("VOICE_WAV and VOICE_TEXT must be set together")

synth_lock = threading.Lock()


def _fill_params(text, lang, instruct, seed, steps):
    text_b = text.encode("utf-8")
    lang_b = (lang or "").encode("utf-8")
    instruct_b = (instruct or "").encode("utf-8")
    params = OvTtsParams()
    lib.ov_tts_default_params(ctypes.byref(params))
    params.abi_version = OV_ABI_VERSION
    params.text = text_b
    params.lang = lang_b
    params.instruct = instruct_b
    params.mg_num_step = int(steps)
    if REF_TOKENS is not None:
        params.ref_audio_tokens = ctypes.cast(REF_TOKENS, ctypes.c_void_p)
        params.ref_T = REF_T
        params.ref_text = REF_TEXT_B
    if seed is not None:
        params.mg_seed = ctypes.c_uint64(int(seed)).value
    # Keep refs alive on the params object so the caller doesn't have to.
    params._refs = (text_b, lang_b, instruct_b)
    return params


def synth(text, lang, instruct, seed, steps):
    with synth_lock:
        params = _fill_params(text, lang, instruct, seed, steps)
        audio = OvAudio()
        rc = lib.ov_synthesize(ctx, ctypes.byref(params), ctypes.byref(audio))
        if rc != 0:
            err = lib.ov_last_error()
            msg = err.decode() if err else f"rc={rc}"
            raise RuntimeError(f"ov_synthesize: {msg}")
        try:
            n = audio.n_samples
            sr = audio.sample_rate
            pcm = floats_to_pcm16(audio.samples, n)
            buf = io.BytesIO()
            with wave.open(buf, "wb") as w:
                w.setnchannels(1)
                w.setsampwidth(2)
                w.setframerate(sr)
                w.writeframes(pcm)
            return buf.getvalue()
        finally:
            lib.ov_audio_free(ctypes.byref(audio))


def synth_stream(text, lang, instruct, seed, steps, on_pcm_chunk):
    """Run synthesis with the streaming callback. on_pcm_chunk(bytes) is
    called for every audio chunk (already int16-encoded). Returns
    normally on success; on_pcm_chunk should return True to continue,
    False to abort."""
    # Hold a ref to the cfunctype object so it isn't GC'd mid-call.
    def _trampoline(samples_ptr, n_samples, _ud):
        try:
            return bool(on_pcm_chunk(floats_to_pcm16(samples_ptr, n_samples)))
        except Exception:
            log.exception("on_chunk callback failed")
            return False
    cb = OV_AUDIO_CHUNK_CB(_trampoline)

    with synth_lock:
        params = _fill_params(text, lang, instruct, seed, steps)
        params.on_chunk = ctypes.cast(cb, ctypes.c_void_p)
        audio = OvAudio()
        rc = lib.ov_synthesize(ctx, ctypes.byref(params), ctypes.byref(audio))
        # In streaming mode `audio` stays empty, but free defensively.
        lib.ov_audio_free(ctypes.byref(audio))
        if rc != 0 and rc != -5:  # OV_STATUS_CANCELLED = -5
            err = lib.ov_last_error()
            msg = err.decode() if err else f"rc={rc}"
            raise RuntimeError(f"ov_synthesize: {msg}")


# Two tiers of boundary:
#  - PRIMARY (.!?\n …): always split, end-of-sentence pauses
#  - SECONDARY (,;:—–…): split only if the accumulated chunk is at
#    least MIN_SECONDARY_LEN chars, to avoid tiny choppy fragments.
_PRIMARY_RE = re.compile(r".*?[.!?。！？\n]", re.DOTALL)
_SECONDARY_RE = re.compile(r".*?[,;:—–，；：]", re.DOTALL)
MIN_SECONDARY_LEN = 25


def find_chunk_end(buf):
    m = _PRIMARY_RE.match(buf)
    if m:
        return m.end()
    m = _SECONDARY_RE.match(buf)
    if m and m.end() >= MIN_SECONDARY_LEN:
        return m.end()
    return -1


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            self._send(200, b"ok", "text/plain")
            return
        self.send_error(404)

    def do_POST(self):
        if self.path.split("?", 1)[0] == "/tts/append":
            self._do_tts_append()
            return
        if self.path != "/tts":
            self.send_error(404)
            return
        length = int(self.headers.get("Content-Length", 0))
        try:
            body = json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            self.send_error(400, "invalid JSON")
            return
        text = body.get("text", "").strip()
        if not text:
            self.send_error(400, "missing 'text'")
            return
        lang = body.get("lang", DEFAULT_LANG)
        instruct = body.get("instruct", DEFAULT_INSTRUCT)
        seed = body.get("seed")
        steps = body.get("steps", DEFAULT_STEPS)
        stream = bool(body.get("stream", False))
        log.info("synth: lang=%r instruct=%r steps=%d len=%d clone=%s stream=%s",
                 lang, instruct, steps, len(text), REF_TOKENS is not None, stream)

        if stream:
            self.send_response(200)
            self.send_header("Content-Type", "audio/wav")
            self.send_header("Connection", "close")
            self.end_headers()
            # Streaming WAV header up front; players read until EOF.
            write_streaming_wav_header(self.wfile, 24000)
            self.wfile.flush()

            def push(pcm):
                try:
                    self.wfile.write(pcm)
                    self.wfile.flush()
                    return True
                except (BrokenPipeError, ConnectionResetError):
                    return False
            try:
                synth_stream(text, lang, instruct, seed, steps, push)
            except Exception:
                log.exception("stream synth failed")
                # Headers already sent — best effort: just drop the conn.
            return

        try:
            wav = synth(text, lang, instruct, seed, steps)
        except Exception as e:
            log.exception("synth failed")
            self.send_error(500, str(e))
            return
        self._send(200, wav, "audio/wav")

    def _read_body_chunks(self):
        """Yield bytes chunks from the request body. Supports both
        Content-Length and Transfer-Encoding: chunked."""
        te = self.headers.get("Transfer-Encoding", "").lower()
        if "chunked" in te:
            while True:
                line = self.rfile.readline().strip()
                if not line:
                    break
                try:
                    size = int(line.split(b";", 1)[0], 16)
                except ValueError:
                    break
                if size == 0:
                    # Consume trailers + final CRLF.
                    while self.rfile.readline().strip():
                        pass
                    break
                remaining = size
                while remaining > 0:
                    buf = self.rfile.read(remaining)
                    if not buf:
                        return
                    remaining -= len(buf)
                    yield buf
                self.rfile.readline()  # trailing CRLF after chunk data
            return
        cl = self.headers.get("Content-Length")
        if cl is not None:
            remaining = int(cl)
            while remaining > 0:
                buf = self.rfile.read(min(4096, remaining))
                if not buf:
                    return
                remaining -= len(buf)
                yield buf

    def _do_tts_append(self):
        qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        lang = qs.get("lang", [DEFAULT_LANG])[0]
        instruct = qs.get("instruct", [DEFAULT_INSTRUCT])[0]
        seed = int(qs["seed"][0]) if "seed" in qs else None
        steps = int(qs.get("steps", [str(DEFAULT_STEPS)])[0])

        if self.headers.get("Content-Length") is None and \
           "chunked" not in self.headers.get("Transfer-Encoding", "").lower():
            self.send_error(411, "need Content-Length or Transfer-Encoding: chunked")
            return

        log.info("append: lang=%r instruct=%r steps=%d clone=%s",
                 lang, instruct, steps, REF_TOKENS is not None)

        self.send_response(200)
        self.send_header("Content-Type", "audio/wav")
        self.send_header("Connection", "close")
        self.end_headers()
        write_streaming_wav_header(self.wfile, 24000)
        self.wfile.flush()

        alive = [True]

        def push(pcm):
            if not alive[0]:
                return False
            try:
                self.wfile.write(pcm)
                self.wfile.flush()
                return True
            except (BrokenPipeError, ConnectionResetError):
                alive[0] = False
                return False

        def synth_sentence(sentence):
            if not sentence:
                return True
            log.info("append-synth: len=%d %r", len(sentence), sentence[:60])
            try:
                synth_stream(sentence, lang, instruct, seed, steps, push)
            except Exception:
                log.exception("append synth failed mid-stream")
                alive[0] = False
            return alive[0]

        buf = ""
        for chunk in self._read_body_chunks():
            if not alive[0]:
                return
            buf += chunk.decode("utf-8", errors="replace")
            while True:
                end = find_chunk_end(buf)
                if end < 0:
                    break
                sentence = buf[:end].strip()
                buf = buf[end:]
                if not synth_sentence(sentence):
                    return
        # Flush whatever's left.
        tail = buf.strip()
        if tail and alive[0]:
            synth_sentence(tail)

    def _send(self, code, body, content_type):
        self.send_response(code)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        log.info("%s %s", self.address_string(), fmt % args)


if __name__ == "__main__":
    log.info("ready on %s:%d (model=%s codec=%s)", LISTEN_HOST, LISTEN_PORT,
             MODEL, CODEC)
    try:
        ThreadingHTTPServer((LISTEN_HOST, LISTEN_PORT), Handler).serve_forever()
    finally:
        lib.ov_free(ctx)
