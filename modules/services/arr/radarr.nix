{
  config,
  lib,
  ...
}: {
  options.services.arr.radarr.enable = lib.mkEnableOption "radarr" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.radarr.enable) {
    services.radarr = {
      enable = true;
      group = config.services.arr.group.name;
    };

    services.caddy = {
      enable = true;

      virtualHosts."radarr.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:7878
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/movies 0774 radarr ${toString config.services.arr.group.gid}"
    ];
  };
}
