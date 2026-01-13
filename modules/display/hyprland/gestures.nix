{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf getExe;

  # Toggle squeekboard visibility via DBus
  toggleSqueekboard = pkgs.writeShellScript "toggle-squeekboard" ''
    visible=$(busctl get-property --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 Visible 2>/dev/null | cut -d' ' -f2)
    if [ "$visible" = "true" ]; then
      busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b false
    else
      busctl call --user sm.puri.OSK0 /sm/puri/OSK0 sm.puri.OSK0 SetVisible b true
    fi
  '';
in {
  config = mkIf cfg.enable {
    hm = {
      # Squeekboard systemd user service
      systemd.user.services.squeekboard = {
        Unit = {
          Description = "Squeekboard on-screen keyboard";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = getExe pkgs.squeekboard;
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      wayland.windowManager.hyprland = {
        settings = {
          gestures = {
            workspace_swipe_cancel_ratio = 0.15;
          };

          plugin = {
            touch_gestures = {
              sensitivity = 4.0;
              workspace_swipe_fingers = 3;
              long_press_delay = 200;
              resize_on_border_long_press = true;
              edge_margin = 10;
              emulate_touchpad_swipe = true;

              # Custom gesture bindings
              # Swipe down from top edge → open anyrun
              # 4-finger swipe down → close window
              # 3-finger tap → toggle floating
              # Swipe up from bottom edge → toggle squeekboard
              hyprgrass-bind = [
                ", edge:u:d, exec, uwsm app -- anyrun"
                ", edge:d:u, exec, ${toggleSqueekboard}"
                ", swipe:4:d, killactive"
                ", tap:3, togglefloating"
              ];

              # Long press drag gestures
              hyprgrass-bindm = [
                ", longpress:2, movewindow"
                ", longpress:3, resizewindow"
              ];
            };
          };
        };

        plugins = [
          inputs.hyprgrass.packages.${pkgs.system}.default
        ];
      };
    };
  };
}
