{
  config,
  lib,
  sources,
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
  options.services.smarthome.music-assistant = {
    enable = lib.mkEnableOption "music-assistant" // {default = config.services.smarthome.enable;};
    host = lib.mkOption {
      type = lib.types.str;
      default = "music.neoney.dev";
    };
  };

  config.os = lib.mkMerge [
    (lib.mkIf config.services.smarthome.home-assistant.enable {
      users.groups.home-assistant = {};

      users.users.neoney.extraGroups = ["home-assistant"];

      systemd.tmpfiles.rules = [
        "d /etc/home-assistant 0775 root home-assistant -"
        "d /var/lib/home-assistant-media 0775 root home-assistant -"
        "d /var/lib/matter-server 0755 1000 1000 -"
      ];

      networking.firewall.allowedTCPPorts = [
        80
        8123
        21063
        21064
        21065 # for homekit
      ];

      networking.firewall.allowedUDPPorts = [
        5353
      ];

      virtualisation.oci-containers = {
        backend = "podman";
        containers.homeassistant = {
          volumes = ["/etc/home-assistant:/config" "/var/lib/home-assistant-media:/media"];
          environment.TZ = "Europe/Warsaw";
          image = "homeassistant/home-assistant:${sources.home-assistant.version}";
          imageFile = sources.home-assistant.src;
          extraOptions = [
            "--network=host"
          ];
        };
        containers.matter-server = {
          image = "ghcr.io/matter-js/matterjs-server:0.5.15";
          volumes = ["/var/lib/matter-server:/data"];
          extraOptions = [
            "--network=host"
            "--privileged"
          ];
        };
      };

      services.caddy = {
        enable = true;

        virtualHosts.${config.services.smarthome.home-assistant.host}.extraConfig = ''
          reverse_proxy 127.0.0.1:8123
        '';
      };
    })

    (lib.mkIf config.services.smarthome.music-assistant.enable {
      systemd.tmpfiles.rules = [
        "d /var/lib/music-assistant 0775 root home-assistant -"
      ];

      networking.firewall.allowedTCPPorts = [
        8095 # music assistant web ui
        8097 # music assistant stream port
        8927 # aiosendspin (sendspin player discovery)
      ];

      virtualisation.oci-containers = {
        backend = "podman";
        containers.music-assistant = {
          image = "ghcr.io/music-assistant/server:2.7.11"; # updated manually - nvfetcher can't track GHCR
          volumes = [
            "/var/lib/music-assistant:/data"
            "/var/lib/home-assistant-media:/media"
          ];
          environment = {
            TZ = "Europe/Warsaw";
            LOG_LEVEL = "info";
          };
          extraOptions = [
            "--network=host"
          ];
        };
      };

      services.caddy = {
        enable = true;

        virtualHosts.${config.services.smarthome.music-assistant.host}.extraConfig = ''
          reverse_proxy 127.0.0.1:8095
        '';
      };
    })
  ];
}
