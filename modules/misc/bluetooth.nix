{
  config,
  lib,
  pkgs,
  ...
}: let
  # Only disable BT if no audio devices are connected
  # This prevents disconnecting headphones when docking
  conditionalBtOff = pkgs.writeShellScript "conditional-bt-off" ''
    has_audio=0
    for device in $(${pkgs.bluez}/bin/bluetoothctl devices Connected | cut -d' ' -f2); do
      icon=$(${pkgs.bluez}/bin/bluetoothctl info "$device" | grep "Icon:" | cut -d' ' -f2)
      if echo "$icon" | grep -qE "^audio"; then
        has_audio=1
        break
      fi
    done
    if [ "$has_audio" -eq 0 ]; then
      ${pkgs.bluez}/bin/bluetoothctl power off
    fi
  '';
in {
  options.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf config.bluetooth.enable {
    impermanence.systemDirs = ["/var/lib/bluetooth"];

    os = {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;
        settings = {
          General = {
            Experimental = true; # LE Audio, battery reporting for headphones
            FastConnectable = false; # Lower power when not pairing new devices
          };
        };
      };
      services.blueman.enable = true;

      # Auto-toggle Bluetooth when dock keyboard connects/disconnects
      # Dock keyboard: 05af:326a (Minisforum V3 keyboard dock)
      services.udev.extraRules = ''
        # Dock keyboard disconnected -> enable Bluetooth for Corne
        ACTION=="remove", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="05af", ENV{ID_MODEL_ID}=="326a", RUN+="${pkgs.bluez}/bin/bluetoothctl power on"
        # Dock keyboard connected -> disable Bluetooth only if no other devices (besides Corne) connected
        ACTION=="add", SUBSYSTEM=="usb", ENV{ID_VENDOR_ID}=="05af", ENV{ID_MODEL_ID}=="326a", RUN+="${conditionalBtOff}"
      '';
    };
  };
}
