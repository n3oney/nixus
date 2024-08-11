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
                ".config/obsidian"
                ".config/kdeconnect"
              ]
              ++ (lib.optionals config.programs.curaSlicer.enable [".config/cura" ".local/share/cura"])
              ++ (lib.optionals config.programs.orcaSlicer.enable [".config/OrcaSlicer" ".local/share/orca-slicer"])
              ++ (lib.optionals config.programs.jellyfinPlayer.enable [".config/jellyfin.org" ".local/share/jellyfinmediaplayer" ".local/share/Jellyfin Media Player" ".cache/Jellyfin Media Player"]))
            ++ ["/var/lib/waydroid" "/etc/nixos" "/etc/NetworkManager" "/var/log" "/var/lib" "/etc/nix" "/etc/ssh" "/var/db/sudo" "/var/lib/minecraft" "/var/lib/bluetooth"];
          files = ["/etc/machine-id" "/home/neoney/.cache/anyrun-ha-assist.sqlite3" "/home/neoney/.local/share/fish/fish_history" "/home/neoney/.config/nushell/history.txt"];
        };

        users = {
          mutableUsers = false;
          users.neoney.initialHashedPassword = "$6$hAv60khFN/SnCt6r$LkoM5y7xGJPBGLr8DoNZB.mKJudpctUVZ75meQ6gTHBdp8q.dOmXgfTzZOw1.igi1gBc451Hc69TrUmqtFFqB.";
          users.root.hashedPasswordFile = "/persist/passwords/root";
          users.neoney.hashedPasswordFile = "/persist/passwords/neoney";
        };

        programs.fuse.userAllowOther = true;
      };
    })
  ];
}
