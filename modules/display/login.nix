{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  config = lib.mkIf config.display.enable {
    os = let
      hyprlandCfg = hmConfig.wayland.windowManager.hyprland.settings;

      nwg-hello = pkgs.nwg-hello.overrideAttrs (oldAttrs: {
        postPatch =
          (oldAttrs.postPatch or "")
          + ''
            substituteInPlace nwg_hello/main.py \
              --replace "$out/etc/nwg-hello/nwg-hello.json" "/etc/nwg-hello/nwg-hello.json" \
              --replace "$out/etc/nwg-hello/nwg-hello.css" "/etc/nwg-hello/nwg-hello.css"

            substituteInPlace nwg-hello-default.css \
              --replace "/usr/share/nwg-hello/nwg.jpg" "$out/share/nwg-hello/nwg.jpg"
          '';
      });

      greetdHyprlandConfig = pkgs.writeText "greetd-hyprland-config" (
        hmConfig.lib.generators.toHyprconf {
          importantPrefixes = ["$" "bezier" "name" "output"];
          attrs = {
            inherit (hyprlandCfg) input general monitor decoration animations dwindle misc;

            # Use GTK theme from ./gtk.nix
            env =
              (hyprlandCfg.env or [])
              ++ [
                "GTK_THEME,${hmConfig.gtk.theme.name}"
              ];

            debug.disable_logs = false;

            exec-once = [
              "hyprctl setcursor ${hmConfig.home.pointerCursor.name} ${toString hmConfig.home.pointerCursor.size}"
              # No --layer-shell, because Hyprland doesn't focus it by default.
              "${nwg-hello}/bin/nwg-hello; hyprctl dispatch exit"
            ];
          };
        }
      );

    in {
      # Make session files available in /run/current-system/sw/share/
      environment.pathsToLink = [
        "/share/wayland-sessions"
        "/share/xsessions"
      ];

      environment.etc."nwg-hello/nwg-hello.json".text = builtins.toJSON {
        # Use standard system session paths
        session_dirs = [
          "/run/current-system/sw/share/wayland-sessions"
          "/run/current-system/sw/share/xsessions"
        ];
        custom_sessions = [];
        # Use GTK theme from user config
        gtk-theme = hmConfig.gtk.theme.name;
        gtk-icon-theme = hmConfig.gtk.iconTheme.name;
        gtk-cursor-theme = hmConfig.home.pointerCursor.name;
        prefer-dark-theme = true;
        # Delay for multi-monitor setups
        delay_secs = 1;
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${config.display.package}/bin/start-hyprland -- --config ${greetdHyprlandConfig}";
          };
        };
      };

      security.pam.services.greetd.enableGnomeKeyring = true;

      # Create cache directory and pre-populate with default session
      systemd.tmpfiles.rules = [
        "d /var/cache/nwg-hello 0755 greeter greeter -"
        "C /var/cache/nwg-hello/cache.json 0644 greeter greeter - ${pkgs.writeText "nwg-hello-cache" (builtins.toJSON {
          sessions.neoney = "uwsm start -e -D Hyprland hyprland.desktop";
          user = "neoney";
        })}"
      ];

      environment.etc."greetd/environments".text = ''
        uwsm start hyprland-uwsm.desktop
        niri-session
      '';
    };
  };
}
