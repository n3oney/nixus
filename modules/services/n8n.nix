{
  lib,
  config,
  pkgs,
  ...
}: {
  options.services.n8n.enable = lib.mkEnableOption "n8n";

  config.os = lib.mkIf config.services.n8n.enable (let
    port = 55152;
    host = "n8n.neoney.dev";
  in {
    services.n8n = {
      enable = true;
      environment = {
        N8N_PORT = port;
      };
    };

    systemd.services.n8n = {
      path = [pkgs.nodejs pkgs.gnutar pkgs.gzip];
      environment = {
        N8N_PORT = builtins.toString port;
        N8N_PROXY_HOPS = "1";
        WEBHOOK_URL = "https://${host}/";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts.${host}.extraConfig = ''
        reverse_proxy 127.0.0.1:${builtins.toString port}
      '';
    };
  });
}
