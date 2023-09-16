{
  config,
  lib,
  ...
}: {
  options.services.adguard = {
    enable = lib.mkEnableOption "AdGuard Home";
    host = lib.mkOption {
      type = lib.types.str;
      default = "adguard.neoney.dev";
    };
  };

  config.os = lib.mkIf config.services.adguard.enable {
    services.adguardhome = {
      enable = true;
      allowDHCP = true;
    };

    networking.firewall.allowedTCPPorts = [
      53
    ];

    networking.firewall.allowedUDPPorts = [
      53
      68
      67
      547
      546
    ];
  };
}
