{
  config,
  lib,
  ...
}: {
  options.bluetooth.enable = lib.mkEnableOption "Bluetooth";

  config.os = lib.mkIf config.bluetooth.enable {
    hardware.bluetooth.enable = true;
    services.blueman.enable = true;
  };
}
