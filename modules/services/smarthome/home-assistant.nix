{
  config,
  lib,
  ...
}: {
  options.services.smarthome.enable = lib.mkEnableOption "Smart Home";
  options.services.smarthome.home-assistant.enable = lib.mkEnableOption "home-assistant" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.home-assistant.enable {
    networking.firewall.allowedTCPPorts = [
      8123
      21064
      21065 # for homekit
    ];

    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        volumes = ["/etc/home-assistant:/config" "/var/lib/home-assistant-media:/media"];
        environment.TZ = "Europe/Warsaw";
        image = "ghcr.io/home-assistant/home-assistant:stable";
        extraOptions = [
          "--network=host"
        ];
      };
    };
  };
}
