{
  lib,
  config,
  osConfig,
  pkgs,
  ...
}: {
  options.services.librechat.enable = lib.mkEnableOption "LibreChat";

  config =
    lib.mkIf config.services.librechat.enable (let
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
              name = "Mistral";
              apiKey = "user_provided";
              baseURL = "https://api.mistral.ai/v1";
              models = {
                fetch = true;
                default = ["devstral-medium-latest" "mistral-tiny" "mistral-medium" "mistral-large-latest"];
              };
              titleConvo = true;
              titleModel = "mistral-tiny";
              modelDisplayLabel = "Mistral";
              dropParams = ["stop" "user" "frequency_penalty" "presence_penalty"];
            }
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
          mysql = {
            startup = false;
            type = "stdio";
            command = "npx";
            args = ["-y" "@kevinwatt/mysql-mcp"];
            env = {
              MYSQL_HOST = "{{MYSQL_HOST}}";
              MYSQL_PORT = "{{MYSQL_PORT}}";
              MYSQL_USER = "{{MYSQL_USER}}";
              MYSQL_PASS = "{{MYSQL_PASSWORD}}";
              MYSQL_DB = "{{MYSQL_DB}}";
            };
            customUserVars = {
              MYSQL_HOST = {
                title = "MySQL host";
                description = "Host to connect to";
              };
              MYSQL_PORT = {
                title = "MySQL port";
                description = "Port to connect to";
              };
              MYSQL_USER = {
                title = "MySQL user";
                description = "User to connect as";
              };
              MYSQL_PASSWORD = {
                title = "MySQL password";
                description = "Password to authenticate with";
              };
              MYSQL_DB = {
                title = "MySQL database";
                description = "Database to use";
              };
            };
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
          csharp = {
            startup = false;
            type = "stdio";
            command = "dotnet";
            args = ["run" "--project" "/tmp/mcp-csharp"];
            description = "C# code execution and analysis server";
          };
        };
      };
      settingsYaml = pkgs.writeText "librechat.yaml" (builtins.toJSON settings);

      # Installation script as plain text (no Nix packages)
      installDotnetScript = ''
        #!/bin/sh
        # Check if .NET is already installed
        if ! command -v dotnet >/dev/null 2>&1; then
          echo "Installing .NET SDK..."

          # Update package lists and install prerequisites
          apt-get update
          apt-get install -y \
            wget \
            gpg \
            curl

          # Add Microsoft package repository
          wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
          dpkg -i packages-microsoft-prod.deb
          rm packages-microsoft-prod.deb

          # Update package lists and install .NET SDK
          apt-get update
          apt-get install -y dotnet-sdk-8.0

          # Clean up
          apt-get clean
          rm -rf /var/lib/apt/lists/*

          echo ".NET SDK installed successfully"
        else
          echo ".NET SDK already installed"
        fi

        # Verify installation
        dotnet --version

        # Create MCP C# server directory and clone the repository
        if [ ! -d "/tmp/mcp-csharp" ]; then
          echo "Setting up MCP C# server..."
          cd /tmp
          git clone https://github.com/modelcontextprotocol/servers.git mcp-csharp
          cd mcp-csharp/src/csharp
          dotnet restore
          dotnet build
          echo "MCP C# server setup completed"
        fi
      '';

      container =
        pkgs.dockerTools.buildLayeredImage {
          name = "librechat-dev-custom";
          tag = "latest";

          # Base on the existing image
          fromImage = pkgs.dockerTools.pullImage {
            imageName = "ghcr.io/danny-avila/librechat-dev";
            imageDigest = "sha256:0049f5ad6147967ce6e0783876f02c817f0596bce5825a8ddd86b7598aa55b6f";
            hash = "sha256-tlidIsOAAtEXVzwOmcFwGpdJ+CYczbxJnnUOiHAVLQ0=";
            finalImageName = "ghcr.io/danny-avila/librechat-dev";
            finalImageTag = "latest";
          };

          # Empty contents - use base image as-is
          contents = [];

          # Extra configuration
          config = {
            Env = [
              "HOST=0.0.0.0"
            ];
            WorkingDir = "/app";
            # Install .NET using the base image's tools, then start the application
            Cmd = ["/bin/sh" "-c" "
set +e
echo 'Installing .NET SDK and dotnet-script...'
apk update || true
apk add --no-cache dotnet8-sdk git || echo 'Failed to install .NET SDK, continuing...'
if command -v dotnet >/dev/null 2>&1; then
  # Install dotnet-script as a .NET tool (modern alternative to scriptcs)
  dotnet tool install --global dotnet-script
  # Add global tools to PATH
  export PATH=$PATH:/root/.dotnet/tools
  echo 'export PATH=\$PATH:/root/.dotnet/tools' >> /etc/profile
  # Create scriptcs alias for dotnet-script
  ln -sf /root/.dotnet/tools/dotnet-script /usr/local/bin/scriptcs 2>/dev/null || echo 'Creating scriptcs alias...'
  echo 'alias scriptcs=\"dotnet-script\"' >> /etc/profile
  echo 'dotnet-script installed (use scriptcs or dotnet-script command)'
else
  echo 'Failed to install .NET SDK'
fi
echo 'Starting LibreChat...'
exec npm run backend
"];
          };
        };
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
            image = "librechat-dev-custom:latest";
            imageFile = container;
            environment = {
              PORT = builtins.toString port;
              HOST = "127.0.0.1";
              MONGO_URI = "mongodb://localhost:27017/LibreChat";
              ALLOW_UNVERIFIED_EMAIL_LOGIN = "true";
              ALLOW_REGISTRATION = "false";
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
