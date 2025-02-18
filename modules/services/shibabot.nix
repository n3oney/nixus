{
  lib,
  config,
  osConfig,
  inputs,
  ...
}: {
  options.services.shibabot.enable = lib.mkEnableOption "ShibaBot";

  config.os = lib.mkIf config.services.shibabot.enable {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-shibabot"];
      externalInterface = "eth0";
      enableIPv6 = true;
    };

    users.users.shibabot = {
      isSystemUser = true;
      group = "nogroup";
      uid = 21371;
    };

    containers.shibabot = {
      autoStart = true;
      enableTun = true;
      privateNetwork = true;
      hostAddress = "10.0.0.252";
      localAddress = "10.0.0.4";

      bindMounts = {
        "/etc/env" = {
          isReadOnly = true;
          hostPath = osConfig.age.secrets.shibabot.path;
        };
      };

      config = {pkgs, ...}: {
        services.postgresql = {
          enable = true;
          ensureDatabases = ["shibabot"];
          enableTCPIP = true;
          settings.port = 5432;
          authentication = pkgs.lib.mkOverride 10 ''
            local all all trust

            host all all 0.0.0.0/0 trust
          '';
          initialScript = pkgs.writeText "initScript" ''
            CREATE ROLE shibabot WITH LOGIN PASSWORD 'shibabot' CREATEDB;
            CREATE DATABASE shibabot;
            GRANT ALL PRIVILEGES ON DATABASE shibabot TO shibabot;
            ALTER DATABASE shibabot OWNER TO shibabot;
          '';
        };

        users.users.shibabot = {
          isSystemUser = true;
          group = "nogroup";
          uid = 21371;
        };

        systemd.services.shibabot = let
          shibabot = pkgs.buildNpmPackage {
            pname = "shibabot";
            version = "unstable-2024-05-18";

            buildInputs = [pkgs.prisma-engines pkgs.openssl];

            PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";

            PRISMA_CLI_QUERY_ENGINE_TYPE = "binary";
            PRISMA_CLIENT_QUERY_ENGINE_TYPE = "binary";
            PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
            PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";

            src = inputs.shibabot;

            npmDepsHash = "sha256-Aw8BInfK2L3lvgRYuKgA6g/BLkZ7I1EFhAPVVph8mAo=";
            makeCacheWritable = true;
          };
        in {
          enable = true;
          environment = {
            DATABASE_URL = "postgres://shibabot:shibabot@127.0.0.1:5432/shibabot";
            PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";

            PRISMA_CLI_QUERY_ENGINE_TYPE = "binary";
            PRISMA_CLIENT_QUERY_ENGINE_TYPE = "binary";
            PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
            PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
          };
          description = "ShibaBot2";
          wantedBy = ["multi-user.target"];
          after = ["postgresql.service"];
          requires = ["postgresql.service"];
          serviceConfig = {
            Restart = "on-failure";
            RestartSec = "5s";
            User = "shibabot";
            EnvironmentFile = "/etc/env";
            # ExecStartPre = "${pkgs.nodejs}/bin/npm exec --prefix ${shibabot}/lib/node_modules/shibabot2 prisma migrate deploy";
            ExecStart = "${pkgs.nodejs}/bin/node ${shibabot}/lib/node_modules/shibabot2";
          };
        };

        system.stateVersion = "23.11";
      };
    };
  };
}
