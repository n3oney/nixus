{
  lib,
  config,
  ...
}: {
  options.services.clewdr = {
    enable = lib.mkEnableOption "Clewdr";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8484;
    };
  };

  config.os = lib.mkIf config.services.clewdr.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers.clewdr = {
        image = "ghcr.io/xerxes-2/clewdr:latest";
        autoStart = true;

        # ports = [
        #   "127.0.0.1:${toString config.services.clewdr.port}:8484"
        # ];

        volumes = [
          "/var/lib/clewdr:/etc/clewdr"
        ];

        extraOptions = [
          "--network=host"
        ];

        environment = {
          CLEWDR_IP = "0.0.0.0";
          CLEWDR_PORT = "8484";
          TZ = "Europe/Warsaw";
        };
      };
    };
  };
}
