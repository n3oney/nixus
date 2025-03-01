{
  config,
  lib,
  inputs,
  ...
}: {
  options.impermanence.enable = lib.mkEnableOption "impermanence";

  config = lib.mkMerge [
    (lib.mkIf config.impermanence.enable {
      osModules = [inputs.impermanence.nixosModule];

      os = {
        environment.persistence."/persist" = {
          directories =
            builtins.map (v: {
              directory = "/home/neoney/${v}";
              user = "neoney";
              group = "users";
            }) ([
                ".config/sops"
                ".local/share/waydroid"
                "nixus"
                "Downloads"
                "Games"
                "code"
                "Documents"
                "Kooha"
                "Music"
                ".ssh"
                ".local/share/direnv"
                ".mozilla"
                ".thunderbird"
                ".local/share/Steam"
                ".steam"
                ".local/share/TelegramDesktop"
                ".gnupg"
                ".config/.wrangler"
                ".config/Caprine"
                ".config/vesktop"
                ".config/YouTube Music"
                ".cache/starship"
                ".local/share/nheko"
                ".config/nheko"
                ".config/Element"
                ".local/share/keyrings"
                ".cache/nix-index"
                ".config/obs-studio"
                ".local/share/pnpm/store"
                ".local/share/PrismLauncher"
                ".bun"
                ".yarn"
                ".local/share/zoxide"
                ".xonotic"
                ".local/share/emacs"
                ".platformio"
                ".config/kdeconnect"
                ".local/share/bottles"
                ".config/workpuls-agent"
                ".zen"
                ".config/zed"
                ".local/share/zed/copilot"
                ".local/share/zed/languages/eslint"
                ".config/github-copilot"
                ".config/spotify"
                ".config/JetBrains"
                ".local/share/JetBrains"

                ".phase"
              ]
              ++ (lib.optionals config.programs.curaSlicer.enable [".config/cura" ".local/share/cura"])
              ++ (lib.optionals config.programs.orcaSlicer.enable [".config/OrcaSlicer" ".local/share/orca-slicer"]))
            ++ ["/var/lib/syncthing/.config/syncthing" "/var/lib/cloudflare-warp" "/var/lib/waydroid" "/etc/nixos" "/etc/NetworkManager" "/var/log" "/var/lib" "/etc/nix" "/etc/ssh" "/var/db/sudo" "/var/lib/minecraft" "/var/lib/bluetooth"];
          files = ["/home/neoney/.wakatime.cfg" "/etc/machine-id" "/home/neoney/.cache/anyrun-ha-assist.sqlite3" "/home/neoney/.local/share/fish/fish_history" "/home/neoney/.config/nushell/history.txt"];
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
