{
  config,
  lib,
  pkgs,
  sources,
  osConfig,
  ...
}: let
  cfg = config.services.norish;
  networkName = "norish-bridge";
  appIP = "10.93.0.2";
  dbIP = "10.93.0.3";
  redisIP = "10.93.0.4";
  chromeIP = "10.93.0.5";
in {
  options.services.norish = {
    enable = lib.mkEnableOption "Norish recipes app";
    host = lib.mkOption {
      type = lib.types.str;
      default = "recipes.neoney.dev";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 13781;
    };
  };

  config.os = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/norish 0755 root root -"
      "d /var/lib/norish/uploads 0755 1000 1000 -"
      "d /var/lib/norish/postgres 0755 root root -"
      "d /var/lib/norish/redis 0755 999 999 -"
    ];

    systemd.services.init-norish-network = {
      description = "Create the podman network bridge for norish.";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "oneshot";
      script = ''
        check=$(${pkgs.podman}/bin/podman network ls | grep "${networkName}" || true)
        if [ -z "$check" ]; then
          ${pkgs.podman}/bin/podman network create --subnet 10.93.0.0/24 ${networkName}
        else
          echo "${networkName} already exists in podman"
        fi
      '';
    };

    virtualisation.oci-containers = {
      backend = "podman";

      containers = {
        norish = {
          image = "norishapp/norish:${sources.norish.version}";
          imageFile = sources.norish.src;
          dependsOn = ["norish-db" "norish-redis" "norish-chrome"];
          ports = ["127.0.0.1:${toString cfg.port}:3000"];
          volumes = [
            "/var/lib/norish/uploads:/app/uploads"
            "/etc/resolv.conf:/etc/resolv.conf:ro"
          ];
          environmentFiles = [osConfig.age.secrets.norish.path];
          environment = {
            DATABASE_URL = "postgres://norish:norish@${dbIP}:5432/norish";
            REDIS_URL = "redis://${redisIP}:6379";
            CHROME_WS_ENDPOINT = "ws://${chromeIP}:3000";
            AUTH_URL = "https://${cfg.host}";
            UPLOADS_DIR = "/app/uploads";
            TZ = "Europe/Warsaw";
          };
          extraOptions = ["--network=${networkName}" "--ip=${appIP}" "--add-host=host-gateway:host-gateway" "--device=/dev/dri/renderD128"];
        };

        norish-db = {
          image = "docker.io/postgres:17-alpine";
          volumes = ["/var/lib/norish/postgres:/var/lib/postgresql/data"];
          environment = {
            POSTGRES_USER = "norish";
            POSTGRES_PASSWORD = "norish";
            POSTGRES_DB = "norish";
          };
          extraOptions = ["--network=${networkName}" "--ip=${dbIP}"];
        };

        norish-redis = {
          image = "docker.io/redis:8.4.0";
          volumes = ["/var/lib/norish/redis:/data"];
          extraOptions = ["--network=${networkName}" "--ip=${redisIP}"];
        };

        norish-chrome = {
          image = "docker.io/zenika/alpine-chrome:124";
          cmd = [
            "--no-sandbox"
            "--disable-gpu"
            "--disable-dev-shm-usage"
            "--remote-debugging-address=0.0.0.0"
            "--remote-debugging-port=3000"
            "--headless"
          ];
          volumes = ["/etc/resolv.conf:/etc/resolv.conf:ro"];
          extraOptions = ["--network=${networkName}" "--ip=${chromeIP}"];
        };
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts.${cfg.host}.extraConfig = ''
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };

    # Allow the norish bridge network to reach host services (e.g. local llm later :P)
    networking.firewall.extraCommands = ''
      iptables -I INPUT -s 10.93.0.0/24 -j ACCEPT
    '';
    networking.firewall.extraStopCommands = ''
      iptables -D INPUT -s 10.93.0.0/24 -j ACCEPT || true
    '';
  };
}
