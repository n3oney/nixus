{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.services.mssql;
in {
  options.services.mssql = {
    enable = lib.mkEnableOption "Azure SQL Edge (MSSQL) server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 1433;
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the MSSQL port in the firewall.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.podman.enable = true;

    os = {
      virtualisation.oci-containers = {
        backend = "podman";

        containers.mssql = {
          image = "mcr.microsoft.com/azure-sql-edge:1.0.7";
          ports = ["${toString cfg.port}:1433"];
          # Named podman volume; copy-up gives it the image's mssql:10001 ownership.
          volumes = ["mssql-data:/var/opt/mssql"];
          # MSSQL_SA_PASSWORD comes from the agenix-managed env file.
          environmentFiles = [osConfig.age.secrets.mssql.path];
          environment = {
            ACCEPT_EULA = "1";
            MSSQL_PID = "Developer";
          };
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
    };
  };
}
