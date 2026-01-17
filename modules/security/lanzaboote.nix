{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.security.lanzaboote.enable = lib.mkEnableOption "Lanzaboote";

  config = lib.mkIf config.security.lanzaboote.enable {
    os = {
      environment.systemPackages = [ pkgs.sbctl ];

      boot.loader.systemd-boot.enable = lib.mkForce false;
      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/var/lib/sbctl";
      };
    };
  };
}
