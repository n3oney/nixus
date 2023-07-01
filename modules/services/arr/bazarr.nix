{
  config,
  lib,
  ...
}: {
  options.services.arr.bazarr.enable = lib.mkEnableOption "bazarr" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.bazarr.enable) {
    services.bazarr = {
      enable = true;
      group = config.services.arr.group.name;
    };

    services.caddy = {
      enable = true;

      virtualHosts."bazarr.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:6767
      '';
    };
  };
}
