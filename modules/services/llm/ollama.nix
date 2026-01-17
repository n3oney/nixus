{
  pkgs,
  config,
  lib,
  ...
}: {
  options.services.ollama.enable = lib.mkEnableOption "ollama";

  config = lib.mkIf config.services.ollama.enable (let
    llm =
      pkgs.llm.withPlugins {llm-ollama = true;};
  in {
    os.services.ollama = {
      package = pkgs.ollama-vulkan;
      enable = true;
    };

    os.environment.systemPackages = [
      llm
      (pkgs.writeShellScriptBin "yo" ''
        exec ${llm}/bin/llm -m "qwen2.5:7b-instruct-q4_K_M" "$*"
      '')
    ];
  });
}
