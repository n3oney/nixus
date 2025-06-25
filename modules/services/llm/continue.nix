{
  config,
  lib,
  ...
}: {
  config.hm = lib.mkIf config.services.ollama.enable {
    home.file.".continue/config.yaml".text = builtins.toJSON {
      name = "Local Assistant";
      version = "1.0.0";
      schema = "v1";
      models = [
        {
          name = "DeepSeek R1 Distill Qwen 14B";
          provider = "ollama";
          model = "hf.co/mradermacher/DeepSeek-R1-Distill-Qwen-14B-GGUF:Q4_K_M";
          roles = ["chat" "edit"];
          capabilities = ["tool_use"];
          contextLength = 9000;
        }
      ];
      context = [
        {
          provider = "code";
        }
        {
          provider = "docs";
        }
        {
          provider = "diff";
        }
        {
          provider = "terminal";
        }
        {
          provider = "problems";
        }
        {
          provider = "folder";
        }
        {
          provider = "codebase";
        }
      ];
    };
  };
}
