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
    earlySystemFiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.impermanence.enable {
      osModules = [inputs.preservation.nixosModules.default];

      impermanence = {
        userDirs = [
          ".cache"
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
          ".local/share/keyrings"

          ".local/share/pnpm/store"
          ".bun"
          ".yarn"

          ".phase"

          ".config/github-copilot"
        ];

        systemDirs = [
          "/etc/nixos"
          "/etc/nix"
          "/var/lib"
          "/var/log"
          "/var/db/sudo"
        ];
      };

      os = {
        systemd.tmpfiles.rules = [
          "d /home/neoney/.local - neoney users - -"
        ];
        boot.initrd.systemd.enable = true;
        preservation = {
          enable = true;
          preserveAt."/persist" = {
            directories =
              builtins.map (v: {
                directory = "/home/neoney/${v}";
                user = "neoney";
                group = "users";
                configureParent = true;
                parent = {
                  group = "users";
                  user = "neoney";
                };
              })
              (lib.lists.unique config.impermanence.userDirs)
              ++ config.impermanence.systemDirs;
            files =
              builtins.map (v: {
                file = "/home/neoney/${v}";
                configureParent = true;
                user = "neoney";
                group = "users";
                parent = {
                  group = "users";
                  user = "neoney";
                };
              })
              (lib.lists.unique config.impermanence.userFiles)
              ++ config.impermanence.systemFiles
              ++ [
                {
                  file = "/etc/machine-id";
                  inInitrd = true;
                  how = "symlink";
                }
                {
                  file = "/etc/ssh/ssh_host_rsa_key";
                  how = "symlink";
                  configureParent = true;
                }
                {
                  file = "/etc/ssh/ssh_host_ed25519_key";
                  how = "symlink";
                  configureParent = true;
                }
              ];
          };
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
