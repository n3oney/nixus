{
  config,
  lib,
  ...
}: {
  options.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config = lib.mkIf config.bluetooth.enable {
    impermanence.systemDirs = ["/var/lib/bluetooth"];

    os = {
      hardware.bluetooth.enable = true;
      services.blueman.enable = true;
    };
  };
}
