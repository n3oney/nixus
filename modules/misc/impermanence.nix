{
  config,
  lib,
  inputs,
  ...
}: {
  options.impermanence.enable = lib.mkEnableOption "impermanence";

  config = lib.mkMerge [
    {
      inputs.impermanence.url = "github:nix-community/impermanence";
    }
    (lib.mkIf config.impermanence.enable {
      hmModules = [inputs.impermanence.nixosModules.home-manager.impermanence];
      osModules = [inputs.impermanence.nixosModule];

      os = {
        environment.persistence."/persist" = {
          directories = ["/etc/nixos" "/etc/NetworkManager" "/var/log" "/var/lib" "/etc/nix" "/etc/ssh" "/var/db/sudo"];
          files = ["/etc/machine-id"];
        };

        users = {
          mutableUsers = false;
          users.neoney.initialHashedPassword = "$6$hAv60khFN/SnCt6r$LkoM5y7xGJPBGLr8DoNZB.mKJudpctUVZ75meQ6gTHBdp8q.dOmXgfTzZOw1.igi1gBc451Hc69TrUmqtFFqB.";
          users.root.hashedPasswordFile = "/persist/passwords/root";
          users.neoney.hashedPasswordFile = "/persist/passwords/neoney";
        };

        programs.fuse.userAllowOther = true;
      };

      hm = {
        home.homeDirectory = "/home/neoney";
        home.username = "neoney";

        home.persistence."/persist/home/neoney" = {
          directories =
            [
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
              {
                directory = ".local/share/Steam";
                method = "symlink";
              }
              {
                directory = ".steam";
                method = "symlink";
              }
              ".local/share/TelegramDesktop"
              ".gnupg"
              ".config/.wrangler"
              ".config/Caprine"
              ".config/WebCord"
              ".config/YouTube Music"
              ".cache/starship"
              ".local/share/nheko"
              ".config/nheko"
              ".config/SchildiChat"
              ".local/share/keyrings"
              ".cache/nix-index"
              ".config/obs-studio"
              ".local/share/pnpm/store"
              ".bun"
              {
                directory = ".local/share/zoxide";
                method = "symlink";
              }
            ]
            ++ (lib.optionals config.programs.jellyfinPlayer.enable [".config/jellyfin.org" ".local/share/jellyfinmediaplayer" ".local/share/Jellyfin Media Player" ".cache/Jellyfin Media Player"]);
          files = [
            ".cache/anyrun-ha-assist.sqlite3"
            ".local/share/fish/fish_history"
          ];
          allowOther = true;
        };
      };
    })
  ];
}
