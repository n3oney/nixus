{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # Find the main monitor
  mainMonitor = lib.findFirst (m: m.isMain) (builtins.head cfg.monitors) cfg.monitors;

  # Monitor config values
  monitorName = mainMonitor.name;
  monitorWidth = toString mainMonitor.width;
  monitorHeight = toString mainMonitor.height;
  monitorRefresh = toString mainMonitor.refreshRate;
  monitorScale = toString mainMonitor.scale;

  # Simple rotation script that polls accelerometer and rotates via hyprctl
  rotateScript = pkgs.writeShellScript "auto-rotate" ''
    ACCEL=/sys/bus/iio/devices/iio:device1
    MONITOR="${monitorName}"
    MODE="${monitorWidth}x${monitorHeight}@${monitorRefresh}"
    SCALE="${monitorScale}"
    THRESHOLD=10000

    get_orientation() {
      x=$(cat "$ACCEL/in_accel_x_raw")
      y=$(cat "$ACCEL/in_accel_y_raw")
      # Invert Y axis (sensor is mounted inverted)
      y=$((-y))

      if (( y < -THRESHOLD )); then
        echo 0  # normal landscape
      elif (( y > THRESHOLD )); then
        echo 2  # inverted landscape (180)
      elif (( x > THRESHOLD )); then
        echo 3  # portrait right (270) - swapped
      elif (( x < -THRESHOLD )); then
        echo 1  # portrait left (90) - swapped
      else
        echo -1  # flat/unknown
      fi
    }

    last_orient=-1
    while true; do
      orient=$(get_orientation)
      if [[ "$orient" != "-1" && "$orient" != "$last_orient" ]]; then
        # Legacy monitor syntax: name, resolution@rate, position, scale, transform, N
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "$MONITOR, $MODE, 0x0, $SCALE, transform, $orient" > /dev/null
        # Also rotate touch input to match display
        ${pkgs.hyprland}/bin/hyprctl keyword input:touchdevice:transform "$orient" > /dev/null
        ${pkgs.hyprland}/bin/hyprctl keyword input:tablet:transform "$orient" > /dev/null
        last_orient=$orient
      fi
      sleep 0.5
    done
  '';
in {
  config = mkIf cfg.enable {
    # Fix inverted accelerometer rotation for Minisforum V3
    # SMOCF05 is the native ACPI ID (used with kernel patch)
    os.services.udev.extraHwdb = ''
      sensor:modalias:acpi:SMOCF05*:dmi:*svnMicroComputer*:pnV3:*
        ACCEL_MOUNT_MATRIX=-1, 0, 0; 0, -1, 0; 0, 0, -1
    '';

    # Auto-rotation systemd user service
    hm.systemd.user.services.auto-rotate = {
      Unit = {
        Description = "Auto-rotate display based on accelerometer";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${rotateScript}";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
