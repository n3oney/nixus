{
  config,
  lib,
  ...
}: {
  options.services.arr.jellyfin.enable = lib.mkEnableOption "jellyfin" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.jellyfin.enable) {
    services.jellyfin = {
      enable = true;
      group = config.services.arr.group.name;
    };

    services.caddy = {
      enable = true;

      virtualHosts."jellyfin.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:8096
      '';
    };
  };
}
