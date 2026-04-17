{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  shaderc,
  vulkan-headers,
  vulkan-loader,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "omnivoice-cpp";
  version = "unstable-2026-05-26";

  src = fetchFromGitHub {
    owner = "ServeurpersoCom";
    repo = "omnivoice.cpp";
    rev = "5dff3f17a3e0a73353d8bea35e0fa322fc6dcfdf";
    fetchSubmodules = true;
    hash = "sha256-L5068OCtDbU2taUiaoPxA4RqNCl7DpU5vCPfSOczzdw=";
  };

  nativeBuildInputs = [cmake shaderc];
  buildInputs = [vulkan-headers vulkan-loader];

  cmakeFlags = [
    (lib.cmakeBool "GGML_VULKAN" true)
    (lib.cmakeBool "GGML_NATIVE" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" false)
    (lib.cmakeBool "OMNIVOICE_SHARED" true)
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib $out/include
    install -m755 omnivoice-tts $out/bin/
    install -m755 omnivoice-codec $out/bin/
    install -m755 quantize $out/bin/omnivoice-quantize
    install -m755 libomnivoice.so $out/lib/
    install -m644 ../src/omnivoice.h $out/include/
    runHook postInstall
  '';

  meta = {
    description = "C++17/GGML port of OmniVoice multilingual zero-shot TTS";
    homepage = "https://github.com/ServeurpersoCom/omnivoice.cpp";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "omnivoice-tts";
  };
})
