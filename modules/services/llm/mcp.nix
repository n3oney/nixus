{
  config,
  lib,
  pkgs,
  ...
}: {
  config.hm = lib.mkIf config.services.ollama.enable {
    xdg.configFile."github-copilot/global-copilot-instructions.md".text = ''
      Use context7. The shell used on the system is Nushell, not bash.
    '';

    xdg.configFile."github-copilot/mcp.json".text = builtins.toJSON (let
      npx = "${pkgs.nodejs}/bin/npx";
      envArgs = [
        "-y"
        "envmcp"
        "--env-file"
        "/run/user/1000/agenix/mcp"
      ];
    in {
      servers = {
        ripgrep = {
          command = npx;
          args = ["-y" "mcp-ripgrep@latest"];
        };
        axiom = {
          command = npx;
          args =
            envArgs
            ++ [
              "${pkgs.podman}/bin/podman"
              "run"
              "-i"
              "--rm"
              "--read-only"
              "-e"
              "AXIOM_TOKEN"
              "-e"
              "AXIOM_URL"
              "-e"
              "AXIOM_ORG"
              "docker.io/acuvity/mcp-server-axiom:v0.0.1"
            ];
        };

        tavily = {
          command = npx;
          args =
            envArgs
            ++ [
              npx
              "-y"
              "tavily-mcp@0.2.2"
            ];
        };

        github = {
          command = npx;
          args =
            envArgs
            ++ [
              "${pkgs.podman}/bin/podman"
              "run"
              "-i"
              "--rm"
              "-e"
              "GITHUB_PERSONAL_ACCESS_TOKEN"
              "ghcr.io/github/github-mcp-server"
            ];
        };

        sequential-thinking = {
          command = npx;
          args = [
            "-y"
            "@modelcontextprotocol/server-sequential-thinking"
          ];
        };

        cloudflare = {
          command = npx;
          args = ["-y" "mcp-remote" "https://docs.mcp.cloudflare.com/sse"];
        };

        context7 = {
          command = npx;
          args = ["-y" "@upstash/context7-mcp"];
        };
      };
    });
  };
}
