{
  config,
  lib,
  inputs,
  ...
}: {
  options.impermanence = {
    enable = lib.mkEnableOption "impermanence";
    userDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    userFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    systemDirs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    systemFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.impermanence.enable {
      osModules = [inputs.impermanence.nixosModule];

      impermanence = {
        userDirs = [
          ".yalc"
          ".config/sops"
          "nixus"
          "Downloads"
          "Games"
          "code"
          "Documents"
          "Kooha"
          "Music"
          ".ssh"
          ".local/share/direnv"
          ".local/share/TelegramDesktop"
          ".gnupg"
          ".config/.wrangler"
          ".cache/starship"
          ".local/share/keyrings"
          ".cache/nix-index"

          ".local/share/pnpm/store"
          ".bun"
          ".yarn"

          ".phase"

          ".platformio"

          ".config/github-copilot"
        ];

        systemFiles = [
          "/etc/machine-id"
        ];

        systemDirs = [
          "/etc/nixos"
          "/etc/nix"
          "/etc/ssh"
          "/var/lib"
          "/var/log"
          "/var/db/sudo"
        ];
      };

      os = {
        environment.persistence."/persist" = {
          directories =
            builtins.map (v: {
              directory = "/home/neoney/${v}";
              user = "neoney";
              group = "users";
            })
            (lib.lists.unique config.impermanence.userDirs)
            ++ config.impermanence.systemDirs;
          files =
            builtins.map (v: {
              file = "/home/neoney/${v}";
              parentDirectory = {
                user = "neoney";
                group = "users";
              };
            })
            (lib.lists.unique config.impermanence.userFiles)
            ++ config.impermanence.systemFiles;
        };

        users = {
          mutableUsers = false;
          users.root.hashedPasswordFile = "/persist/passwords/root";
          users.neoney.hashedPasswordFile = "/persist/passwords/neoney";
        };

        programs.fuse.userAllowOther = true;
      };
    })
  ];
}
