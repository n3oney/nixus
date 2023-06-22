{
  pkgs,
  lib,
  config,
  ...
}: {
  options.services.yubikey-touch-detector.enable = lib.mkEnableOption "YubiKey Touch Detector";

  config.hm.systemd.user.services.yubikey-touch-detector = lib.mkIf config.services.yubikey-touch-detector.enable {
    Unit.Description = "YubiKey touch detector";
    Install.WantedBy = ["graphical-session.target"];
    Service.ExecStart = lib.getExe pkgs.yubikey-touch-detector;
  };
}
