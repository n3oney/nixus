{
  config,
  lib,
  pkgs,
  ...
}: {
  config.hm = lib.mkIf config.services.ollama.enable (let
    npx = "${pkgs.nodejs}/bin/npx";

    envArgs = [
      "-y"
      "envmcp"
      "--env-file"
      "/run/user/1000/agenix/mcp"
    ];

    servers = {
      git = {
        command = npx;
        args = ["-y" "@cyanheads/git-mcp-server"];
      };

      repomix = {
        command = npx;
        args = ["-y" "repomix" "--mcp"];
      };

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

      context7 = {
        command = npx;
        args = ["-y" "@upstash/context7-mcp"];
      };
    };
    instructions = ''
      Use context7 for library documentation. The shell used on the system is Nushell, not bash, so in commands use ';' instead of the shell '&&', or 'and' instead of the boolean '&&'.
      Use the repomix tool for tasks that aren't just the most basic edits.
    '';
  in {
    xdg.configFile."github-copilot/global-copilot-instructions.md".text = instructions;

    programs.vscode.userSettings = {
      mcp.servers = lib.mapAttrs (name: value: value // {type = "stdio";}) servers;

      "github.copilot.chat.codeGeneration.instructions" = [
        {
          text = instructions;
        }
      ];
    };

    xdg.configFile."github-copilot/mcp.json".text = builtins.toJSON {
      servers = servers;
    };
  });
}
