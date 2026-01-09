{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    # iio-sensor-proxy for gyroscope/accelerometer support
    os.hardware.sensor.iio.enable = true;

    hm.wayland.windowManager.hyprland.settings = {
      exec-once = [
        # Gyroscope auto-rotation for tablet (background daemon)
        "uwsm-app -s b -- ${pkgs.iio-hyprland}/bin/iio-hyprland ${cfg.monitors.main.name}"
      ];
    };
  };
}
