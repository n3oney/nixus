{
  pkgs,
  lib,
  config,
  ...
}: {
  options.services.yubikey-touch-detector.enable = lib.mkEnableOption "YubiKey Touch Detector";

  config.h.systemd.services.yubikey-touch-detector = lib.mkIf config.services.yubikey-touch-detector.enable {
    description = "YubiKey touch detector";
    wantedBy = ["graphical-session.target"];
    serviceConfig.ExecStart = "${lib.getExe pkgs.yubikey-touch-detector} --libnotify";
  };
}
