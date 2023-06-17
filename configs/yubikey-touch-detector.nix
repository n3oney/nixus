{
  home = {
    pkgs,
    lib,
    ...
  }: {
    systemd.user.services.yubikey-touch-detector = {
      Unit.Description = "YubiKey touch detector";
      Install.WantedBy = ["graphical-session.target"];
      Service.ExecStart = lib.getExe pkgs.yubikey-touch-detector;
    };
  };
}
