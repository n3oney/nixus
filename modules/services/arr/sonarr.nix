{
  config,
  lib,
  ...
}: {
  options.services.arr.sonarr.enable = lib.mkEnableOption "sonarr" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.sonarr.enable) {
    services.sonarr = {
      group = config.services.arr.group.name;
      enable = true;
    };

    services.caddy = {
      enable = true;

      virtualHosts."sonarr.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8989
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/shows 0774 sonarr ${toString config.services.arr.group.gid}"
    ];
  };
}
