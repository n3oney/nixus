{
  lib,
  pkgs,
  ...
}: let
  greetdSwayConfig = pkgs.writeText "greetd-sway-config" ''
    exec "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP"
    input "type:touchpad" {
      tap enabled
    }
    seat seat0 xcursor_theme Catppuccin-Mocha-Green-Cursors 24

    xwayland disable

    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'

    exec "${lib.getExe pkgs.greetd.gtkgreet} -l; swaymsg exit"
  '';
in {
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe pkgs.sway} --config ${greetdSwayConfig}";
      };
    };
  };

  environment.etc."greetd/environments".text = ''
    Hyprland
  '';
}
