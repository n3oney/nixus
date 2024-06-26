{
  inputs,
  config,
  osConfig,
  lib,
  pkgs,
  ...
}: {
  options.services.uonetplan.enable = lib.mkEnableOption "UonetPlan";

  config.os = lib.mkIf config.services.uonetplan.enable {
    systemd.services.uonetplan = {
      after = ["network-online.target"];
      requires = ["network-online.target"];

      serviceConfig = {
        EnvironmentFile = osConfig.age.secrets.uonetplan.path;
        Type = "simple";
        Restart = "on-failure";
        User = "uonetplan";
        Group = "uonetplan";
        RestartSec = 5;
        ExecStart = "${inputs.uonetplan.defaultPackage.${pkgs.system}}/bin/uonetplan";
      };
    };

    systemd.tmpfiles.rules = [
      "d /etc/uonetplan 1770 uonetplan uonetplan"
    ];

    services.caddy = {
      enable = true;

      virtualHosts."uonet.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8080
      '';
    };

    users.groups.uonetplan = {};
    users.users.uonetplan = {
      isSystemUser = true;
      group = "uonetplan";
    };
  };
}
