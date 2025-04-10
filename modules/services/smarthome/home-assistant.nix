{
  config,
  lib,
  ...
}: {
  options.services.smarthome.enable = lib.mkEnableOption "Smart Home";
  options.services.smarthome.home-assistant = {
    enable = lib.mkEnableOption "home-assistant" // {default = config.services.smarthome.enable;};
    host = lib.mkOption {
      type = lib.types.str;
      default = "home-assistant.neoney.dev";
    };
  };

  config.os = lib.mkIf config.services.smarthome.home-assistant.enable {
    networking.firewall.allowedTCPPorts = [
      80
      8123
      21063
      21064
      21065 # for homekit
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = ["/etc/home-assistant:/config" "/var/lib/home-assistant-media:/media"];
        environment.TZ = "Europe/Warsaw";
        image = "ghcr.io/home-assistant/home-assistant:2025.1";
        extraOptions = [
          "--network=host"
        ];
      };
    };

    services.caddy = {
      enable = true;

      virtualHosts.${config.services.smarthome.home-assistant.host}.extraConfig = ''
        reverse_proxy 127.0.0.1:8123
      '';
    };
  };
}
