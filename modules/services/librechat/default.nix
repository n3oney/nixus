{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}: {
  options.services.librechat.enable = lib.mkEnableOption "LibreChat";

  config = lib.mkIf config.services.librechat.enable (let
    port = 34123;
    settings = {
      version = "1.3.0";
      cache = false;
      endpoints = {
        agents = {
          # (optional) Default recursion depth for agents, defaults to 25
          recursionLimit = 50;
          # (optional) Max recursion depth for agents, defaults to 25
          maxRecursionLimit = 100;
          # (optional) Disable the builder interface for agents
          disableBuilder = false;
          # (optional) Agent Capabilities available to all users. Omit the ones you wish to exclude. Defaults to list below.
          capabilities = ["execute_code" "file_search" "actions" "tools"];
        };
        custom = [
          {
            name = "z.ai";
            baseURL = "https://api.z.ai/api/coding/paas/v4";
            models = {
              default = ["glm-4.5" "glm-4.5-air" "glm-4.6"];
            };
            apiKey = "user_provided";
            iconURL = "https://mintcdn.com/zhipu-32152247/B_E8wI-eiNa1QlPV/logo/dark.svg?fit=max&auto=format&n=B_E8wI-eiNa1QlPV&q=85&s=75deefa9dea5bdbc84d4da68885c267f";
            titleConvo = true;
            titleModel = "glm-4.5-air";
            summarize = true;
            summaryModel = "glm-4.5-air";
          }
        ];
      };

      mcpServers = {
        tavily = {
          type = "stdio";
          command = "npx";
          args = ["-y" "tavily-mcp@latest"];
          env.TAVILY_API_KEY = "{{API_KEY}}";
          startup = false;
          customUserVars = {
            API_KEY = {
              title = "Tavily API key";
              description = "Tavily API key";
            };
          };
        };
        mcp-server-code-runner = {
          type = "stdio";
          command = "npx";
          args = ["-y" "mcp-server-code-runner@latest"];
        };
        openmemory = {
          startup = false;
          type = "stdio";
          command = "npx";
          args = ["-y" "openmemory"];
          env = {
            CLIENT_NAME = "librechat";
            OPENMEMORY_API_KEY = "{{API_KEY}}";
          };
          customUserVars = {
            API_KEY = {
              title = "OpenMemory API key";
              description = "OpenMemory API key";
            };
          };
        };
      };
    };
    settingsYaml = pkgs.writeText "librechat.yaml" (builtins.toJSON settings);
  in {
    os = {
      services.mongodb = {
        enable = true;
      };

      services.caddy = {
        enable = true;
        virtualHosts."librechat.neoney.dev".extraConfig = ''
          reverse_proxy 127.0.0.1:${builtins.toString port}
        '';
      };

      virtualisation.oci-containers = {
        backend = "podman";
        containers.librechat = {
          image = "ghcr.io/danny-avila/librechat-dev:9c77f53454f943e6036ab703912c29215b282826";
          environment = {
            PORT = builtins.toString port;
            HOST = "127.0.0.1";
            MONGO_URI = "mongodb://localhost:27017/LibreChat";
            ALLOW_UNVERIFIED_EMAIL_LOGIN = "true";
            ALLOW_REGISTRATION = "true";
            TZ = "Europe/Warsaw";
          };
          extraOptions = ["--network=host"];
          volumes = ["${settingsYaml}:/app/librechat.yaml" "/app/client/public/images" "/app/uploads" "/app/logs" "/app/api/data"];
          environmentFiles = [
            osConfig.age.secrets.librechat.path
          ];
        };
      };
    };
  });
}
