{
  lib,
  config,
  ...
}: {
  options.services.n8n.enable = lib.mkEnableOption "n8n";

  config.os = lib.mkIf config.services.n8n.enable (let
    port = 55152;
    host = "n8n.neoney.dev";
  in {
    services.n8n = {
      enable = true;
      webhookUrl = "https://${host}/";
    };

    systemd.services.n8n.environment = {
      N8N_PORT = builtins.toString port;
      N8N_PROXY_HOPS = "1";
    };

    services.caddy = {
      enable = true;
      virtualHosts.${host}.extraConfig = ''
        reverse_proxy 127.0.0.1:${builtins.toString port}
      '';
    };
  });
}
