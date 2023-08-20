{
  config,
  lib,
  ...
}: {
  options.services.arr.jackett = {
    enable = lib.mkEnableOption "jackett" // {default = config.services.arr.enable;};
    host = lib.mkOption {
      type = lib.types.str;
      default = "jackett.neoney.dev";
    };
  };

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.jackett.enable) {
    services.jackett = {
      enable = true;
      group = config.services.arr.group.name;
    };

    networking.firewall.allowedTCPPorts = [80];

    services.caddy = {
      enable = true;

      virtualHosts.${config.services.arr.jackett.host}.extraConfig = ''
        reverse_proxy 127.0.0.1:9117
      '';
    };
  };
}
