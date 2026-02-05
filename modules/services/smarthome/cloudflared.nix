{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.smarthome.cloudflared.enable = lib.mkEnableOption "cloudflared" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.cloudflared.enable {
    users.users.cloudflared = {
      group = "cloudflared";
      isSystemUser = true;
    };

    users.groups.cloudflared = {};

    services.cloudflared = {
      enable = true;

      tunnels = {
        "0f297e16-9faa-4d15-ac3a-8ee50cd9888e" = {
          credentialsFile = osConfig.age.secrets.cloudflared.path;
          ingress = {
            ${config.services.sage.host} = "http://localhost:${toString config.services.sage.port}";
            "home-assistant.neoney.dev" = "http://localhost:8123";
            "jackett.neoney.dev" = "http://localhost:9117";
          };
          default = "http_status:404";
        };
      };
    };
  };
}
