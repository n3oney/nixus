{
  config,
  lib,
  ...
}: {
  options.services.ollama.enable = lib.mkEnableOption "ollama";

  config.os = lib.mkIf config.services.ollama.enable {
    services.ollama = {
      enable = true;
      rocmOverrideGfx = "10.3.0";
      loadModels = ["hf.co/mradermacher/DeepSeek-R1-Distill-Qwen-14B-GGUF:Q4_K_M"];
      acceleration = "rocm";
    };
  };
}
