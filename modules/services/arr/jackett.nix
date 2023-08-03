{
  config,
  lib,
  ...
}: {
  options.services.arr.jackett = {
    enable = lib.mkEnableOption "jackett" // {default = config.services.arr.enable;};
    caddy = lib.mkEnableOption "caddy" // {default = true;};
  };

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.jackett.enable) {
    services.jackett = {
      enable = true;
      group = config.services.arr.group.name;
    };

    services.caddy = lib.mkIf config.services.arr.jackett.caddy {
      enable = true;

      virtualHosts."jackett.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:9117
      '';
    };
  };
}
