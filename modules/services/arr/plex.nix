# DEPRECATED
# Plex has been replaced with Jellyfin.
{
  config,
  lib,
  ...
}: {
  options.services.arr.plex.enable = lib.mkEnableOption "plex" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.plex.enable) {
    services.plex = {
      enable = true;
      group = config.services.arr.group.name;
    };

    services.caddy = {
      enable = true;

      virtualHosts."plex.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:32400
      '';
    };

    networking.firewall = {
      allowedTCPPorts = [3005 8324 32469];
      allowedUDPPorts = [1900 5353 32410 32412 32413 32414];
    };
  };
}
