{
  pkgs,
  lib,
  config,
  hmConfig,
  inputs,
  ...
}: {
  options.programs.vicinae.enable = lib.mkEnableOption "vicinae";

  config = lib.mkIf config.programs.vicinae.enable {
    impermanence.userDirs = [
      ".local/share/vicinae/clipboard-data"
      ".local/share/vicinae/favicon-data"
      ".local/share/vicinae/support"
      ".local/share/vicinae/themes"
    ];

    impermanence.userFiles = [
      ".local/share/vicinae/clipboard.db"
      ".local/share/vicinae/favicon"
      ".local/share/vicinae/file-indexer.db"
      ".local/share/vicinae/file-indexer.db-shm"
      ".local/share/vicinae/file-indexer.db-wal"
      ".local/share/vicinae/metadata.json"
      ".local/share/vicinae/script-metadata.json"
      ".local/share/vicinae/vicinae.db"
      # Mutable settings.json vicinae can write runtime state to
      ".config/vicinae/settings.json"
    ];

    # Native messaging host for Vivaldi browser integration
    hm.xdg.configFile."vivaldi/NativeMessagingHosts/com.vicinae.vicinae.json" = lib.mkIf config.programs.vivaldi.enable {
      text = builtins.toJSON {
        name = "com.vicinae.vicinae";
        description = "Vicinae browser integration";
        path = "${hmConfig.programs.vicinae.package}/libexec/vicinae/vicinae-browser-link";
        type = "stdio";
        allowed_origins = [
          "chrome-extension://kcmipingpfbohfjckomimmahknoddnke/"
        ];
      };
    };

    # Declarative settings as a read-only import file.
    # vicinae reads this via the imports key in settings.json.
    # Keeping it separate from settings.json lets vicinae freely write runtime
    # state (visit counts, etc.) to settings.json without clobbering our config.
    # This is useful to figure out the option names from the setting GUI before
    # putting it in the actual config.
    hm.xdg.configFile."vicinae/declarative.json".text = builtins.toJSON {
      pop_to_root_on_close = true;

      fallbacks = [
        "core:search-emojis"
        "files:search"
      ];

      theme = {
        dark.name = "rose-pine-moon";
      };

      providers = {
        "@knoopx/github" = {
          entrypoints.repositories.alias = "gh";
        };
        "@knoopx/nix".entrypoints = {
          home-manager-options.alias = "hm";
          packages.alias = "pkg";
          options.alias = "nix";
        };
      };

      launcher_window = {
        opacity = 0.75;
        blur.enabled = true;
        dim_around = true;
        layer_shell = {
          enabled = true;
          keyboard_interactivity = "exclusive";
          layer = "top";
        };
      };
    };

    # Seed a mutable settings.json that imports declarative.json.
    # Only written if the file doesn't exist or is still a nix store symlink
    # from an old generation — vicinae will own it from there.
    hm.home.activation.vicinaeSeedSettings = hmConfig.lib.dag.entryAfter ["writeBoundary"] ''
      _settings="$HOME/.config/vicinae/settings.json"
      if [ ! -e "$_settings" ] || [ -L "$_settings" ]; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$_settings")"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m644 /dev/null "$_settings"
        if [ -z "$DRY_RUN_CMD" ]; then
          printf '{"imports":["declarative.json"]}\n' > "$_settings"
        fi
      fi
    '';

    hm.programs.vicinae = {
      enable = true;

      package = inputs.vicinae.packages.${pkgs.stdenv.hostPlatform.system}.default;

      systemd = {
        enable = true;
        autoStart = true;
        target = "graphical-session.target";
      };

      useLayerShell = true;

      extensions = let
        extensionsSrc = pkgs.fetchFromGitHub {
          owner = "vicinaehq";
          repo = "extensions";
          rev = "cf30b80f619282d45b1748eb76e784a4f875bb01";
          sha256 = "sha256-KwNv+THKbNUey10q26NZPDMSzYTObRHaSDr81QP9CPY=";
        };
      in [
        (hmConfig.lib.vicinae.mkExtension {
          name = "nix";
          src = extensionsSrc + "/extensions/nix";
        })
        (hmConfig.lib.vicinae.mkExtension {
          name = "bluetooth";
          src = extensionsSrc + "/extensions/bluetooth";
        })
        (hmConfig.lib.vicinae.mkExtension {
          name = "github";
          src = extensionsSrc + "/extensions/github";
        })
        (hmConfig.lib.vicinae.mkRayCastExtension {
          name = "linear";
          rev = "3de88e0dd8da8fedcd414c6b16dba81412f04d83";
          sha256 = "sha256-hyIS8KYTONLDsn/p8MU9eWKoRYfRVlCzStnSzfUqb6s=";
        })
      ];
    };
  };
}
