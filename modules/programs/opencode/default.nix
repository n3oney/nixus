{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  options.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.programs.opencode.enable {
    impermanence.userDirs = [
      ".local/share/opencode"
      ".cache/opencode"
    ];

    hm = {
      programs.opencode = {
        package = inputs.nix-ai-tools.packages.${pkgs.system}.opencode.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./0000-opencode.patch];
        });
        enable = true;
        settings = {
          theme = "system";
          instructions = [".github/copilot-instructions.md"];
          model = "zai-coding-plan/glm-4.6";
          small_model = "zai-coding-plan/glm-4.5-air";
        };
      };
    };
  };
}
