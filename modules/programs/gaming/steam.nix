{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.enable = lib.mkEnableOption "gaming";

  config.os = lib.mkIf config.programs.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    programs.gamemode.enable = true;

    # Steering wheel enabler
    environment.etc."usb_modeswitch.d/046d:c261".text = ''
      # Logitech G920 Racing Wheel
      DefaultVendor=046d
      DefaultProduct=c261
      MessageEndpoint=01
      ResponseEndpoint=01
      TargetClass=0x03
      MessageContent="0f00010142"
    '';

    services.udev.extraRules = ''
      ATTR{idVendor}=="046d", ATTR{idProduct}=="c261", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -c '/etc/usb_modeswitch.d/046d:c261'"
    '';
    services.udev.packages = with pkgs; [usb-modeswitch-data];
  };
}
