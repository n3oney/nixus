{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # Helpers to wrap commands with uwsm-app
  # -s a = app-graphical.slice (GUI apps)
  # -s b = background-graphical.slice (daemons)
  app = cmd: "uwsm-app -- ${cmd}";
  background = cmd: "uwsm-app -s b -- ${cmd}";
in {
  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      exec-once =
        [
          "dbus-update-activation-environment --systemd --all"
          (background "${pkgs.playerctl}/bin/playerctld")
          (app "zen")
          (app (lib.getExe config.programs.discord.finalPackage))

          (background "wlsunset -l 52.2 -L 21")

          "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
        ];
    };
  };
}
