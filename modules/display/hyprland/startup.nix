{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
  lockSequence = "physlock -ldms && ${lib.getExe pkgs.swaylock} && physlock -Ld";
in {
  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      exec-once =
        [
          "dbus-update-activation-environment --systemd --all"
          "${pkgs.playerctl}/bin/playerctld"
          "mako"
          "zen"
          (lib.getExe config.programs.discord.finalPackage)

          "wlsunset -l 52.2 -L 21"

          ''${lib.getExe pkgs.xss-lock} --ignore-sleep -- ${lib.getExe pkgs.bash} -c ${builtins.toJSON lockSequence}''

          ''swayidle timeout 300 '${lockSequence}' timeout 360 'hyprctl dispatch dpms off' timeout 420 'systemctl suspend' resume 'hyprctl dispatch dpms on' timeout 420 'test $(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r ".sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor") -lt 80 && systemctl suspend' ''

          "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
        ]
        ++ (lib.optionals config.programs.ags.enable ["ags"]);
    };
  };
}
