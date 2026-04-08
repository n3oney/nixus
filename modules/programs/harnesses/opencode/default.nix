{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: let
  opencodeNotifierPlugin = import ./opencode-notifier.nix {
    inherit pkgs;
    src = inputs.opencode-notifier;
  };

  opencode = inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.opencode;

  effectPatterns = import ../effect-patterns-skills.nix {inherit pkgs lib inputs;};
  skillConfigFiles = lib.listToAttrs (
    map (name: {
      name = "opencode/skills/${name}/SKILL.md";
      value.source = "${effectPatterns.drv}/${name}/SKILL.md";
    })
    effectPatterns.skillDirs
  );
in {
  options.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.programs.opencode.enable {
    impermanence.userDirs = [
      ".local/share/opencode"
      ".cache/opencode"
      ".local/state/opencode"
    ];

    hm = {
      home.file.".local/state/opencode/model.json".text = builtins.toJSON {
        recent = [];
        variant = {};
        favorite = [
          # {
          #   providerID = "anthropic";
          #   modelID = "claude-opus-4-6";
          # }
          # {
          #   providerID = "anthropic";
          #   modelID = "claude-sonnet-4-6";
          # }
          # {
          #   providerID = "anthropic";
          #   modelID = "claude-haiku-4-5";
          # }
        ];
      };

      xdg.configFile = skillConfigFiles;
      programs.opencode = {
        package = opencode;
        enable = true;
        settings = {
          agent = {
          };
          permission = {
            lsp = "allow";
            "postgresMutable_*" = "ask";
          };
          plugin = [
            "file://${opencodeNotifierPlugin}"

            #"@nick-vi/opencode-type-inject"
          ];
          theme = "system";
          instructions = [".github/copilot-instructions.md"];
        };
      };
    };
  };
}
