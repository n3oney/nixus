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
            inherit (hyprlandCfg) input general monitorv2 decoration animations dwindle misc;

            # Use GTK theme from ./gtk.nix
            env =
              (hyprlandCfg.env or [])
              ++ [
                "GTK_THEME,${hmConfig.gtk.theme.name}"
              ];

            debug.disable_logs = false;

            exec-once = [
              "dbus-update-activation-environment --systemd --all"
              "hyprctl setcursor ${hmConfig.home.pointerCursor.name} ${toString hmConfig.home.pointerCursor.size}"
              # No --layer-shell, because Hyprland doesn't focus it by default.
              "${nwg-hello}/bin/nwg-hello; hyprctl dispatch exit"
              "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
            ];
          };
        }
      );
    in {
      environment.etc."nwg-hello/nwg-hello.json".text = builtins.toJSON {
        session_dirs = ["${hmConfig.wayland.windowManager.hyprland.package}/share/wayland-sessions"];
        custom_sessions = [
          {
            name = "Hyprland (UWSM)";
            exec = "uwsm start hyprland-uwsm.desktop";
          }
        ];
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${lib.getExe config.display.package} --config ${greetdHyprlandConfig}";
          };
        };
      };

      security.pam.services.greetd.enableGnomeKeyring = true;

      environment.etc."greetd/environments".text = ''
        uwsm start hyprland-uwsm.desktop
      '';
    };
  };
}
