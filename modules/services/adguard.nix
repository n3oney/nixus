{
  config,
  lib,
  ...
}: {
  options.services.adguard.enable = lib.mkEnableOption "AdGuard Home";

  config.os = lib.mkIf config.services.adguard.enable {
    services.adguardhome = {
      enable = true;
    };

    networking.firewall.allowedTCPPorts = [
      53
      3000
    ];

    networking.firewall.allowedUDPPorts = [
      53
    ];
  };
}
