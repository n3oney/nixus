{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # Helper to wrap commands with uwsm app
  uwsm = cmd: "uwsm app -- ${cmd}";
in {
  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      exec-once =
        [
          "dbus-update-activation-environment --systemd --all"
          "${pkgs.playerctl}/bin/playerctld"
          (uwsm "zen")
          (uwsm (lib.getExe config.programs.discord.finalPackage))

          (uwsm "wlsunset -l 52.2 -L 21")

          "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
        ]
        ++ (lib.optionals config.programs.ags.enable [(uwsm "ags")]);
    };
  };
}
