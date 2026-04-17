{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.omnivoice;
in {
  options.services.omnivoice = {
    enable = lib.mkEnableOption "OmniVoice TTS HTTP server (omnivoice.cpp, Vulkan)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.omnivoice-cpp;
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11436;
    };

    model = lib.mkOption {
      type = lib.types.path;
      description = "Path to the OmniVoice base GGUF (e.g. omnivoice-base-Q8_0.gguf).";
    };

    codec = lib.mkOption {
      type = lib.types.path;
      description = "Path to the OmniVoice tokenizer GGUF (e.g. omnivoice-tokenizer-Q8_0.gguf).";
    };

    defaultLang = lib.mkOption {
      type = lib.types.str;
      default = "English";
    };

    defaultInstruct = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Default voice style instruction (e.g. 'female, young adult, moderate pitch').";
    };

    defaultSteps = lib.mkOption {
      type = lib.types.ints.between 4 64;
      default = 16;
      description = ''
        Default MaskGIT sampling steps. Upstream default is 32; 16 cuts
        generation time in half with mild quality loss. Override per request
        with `"steps": N` in the body.
      '';
    };

    wavFormat = lib.mkOption {
      type = lib.types.enum ["wav16" "wav24" "wav32"];
      default = "wav16";
    };

    voiceWav = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Reference WAV for voice cloning, loaded once at startup. Must be
        24 kHz mono 16-bit PCM (use `ffmpeg -i in.wav -ar 24000 -ac 1
        -sample_fmt s16 voice.wav` to convert). Set together with
        `voiceText` or leave both null to use voice-design (instruct).
      '';
    };

    voiceText = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Transcript of the reference WAV. Required when `voiceWav` is set.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config.os = lib.mkIf cfg.enable {
    systemd.services.omnivoice = {
      description = "OmniVoice TTS HTTP server (omnivoice.cpp, Vulkan)";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment = {
        AMD_VULKAN_ICD = "RADV";
        HOME = "%S/omnivoice";
        XDG_CACHE_HOME = "%S/omnivoice/cache";
        OMNIVOICE_LIB = "${cfg.package}/lib/libomnivoice.so";
        OMNIVOICE_CODEC_BIN = "${cfg.package}/bin/omnivoice-codec";
        OMNIVOICE_MODEL = cfg.model;
        OMNIVOICE_CODEC = cfg.codec;
        LISTEN_HOST = cfg.host;
        LISTEN_PORT = toString cfg.port;
        DEFAULT_LANG = cfg.defaultLang;
        DEFAULT_INSTRUCT = cfg.defaultInstruct;
        DEFAULT_STEPS = toString cfg.defaultSteps;
        WAV_FORMAT = cfg.wavFormat;
        VOICE_WAV = lib.mkIf (cfg.voiceWav != null) (toString cfg.voiceWav);
        VOICE_TEXT = lib.mkIf (cfg.voiceText != null) cfg.voiceText;
      };

      serviceConfig = {
        ExecStart = "${pkgs.python3}/bin/python3 ${./omnivoice-server.py}";
        DynamicUser = true;
        SupplementaryGroups = ["render" "video"];
        StateDirectory = "omnivoice";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
