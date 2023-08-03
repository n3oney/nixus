{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.smarthome.cloudflared.enable = lib.mkEnableOption "cloudflared" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.cloudflared.enable {
    services.cloudflared = {
      enable = true;

      tunnels = {
        "0f297e16-9faa-4d15-ac3a-8ee50cd9888e" = {
          credentialsFile = osConfig.age.secrets.cloudflared.path;
          ingress = {
            "home-assistant.neoney.dev" = "http://localhost:8123";
            "jackett.neoney.dev" = "http://localhost:9117";
          };
          default = "http_status:404";
        };
      };
    };
  };
}
