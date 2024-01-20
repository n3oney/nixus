{
  config,
  lib,
  osConfig,
  inputs,
  pkgs,
  ...
}: {
  options.services.conduit.enable = lib.mkEnableOption "conduit";

  config.inputs.conduit.url = "gitlab:famedly/conduit/next";

  config.os = lib.mkIf config.services.conduit.enable {
    services.matrix-conduit = {
      package = inputs.conduit.packages.${pkgs.system}.default;
      enable = true;
      settings.global = {
        server_name = "neoney.dev";
        # allow_registration = true;
        database_backend = "rocksdb";
      };
    };

    networking.firewall.allowedTCPPorts = [80 443 8448];

    services.caddy = {
      enable = true;
      virtualHosts."matrix.neoney.dev".extraConfig = ''
        reverse_proxy /_matrix/* [${osConfig.services.matrix-conduit.settings.global.address}]:${toString osConfig.services.matrix-conduit.settings.global.port}
      '';
    };
  };
}
