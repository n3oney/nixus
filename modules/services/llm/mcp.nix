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
      effect = {
        command = npx;
        args = ["-y" "effect-mcp@latest"];
      };

      git = {
        command = npx;
        args = ["-y" "@cyanheads/git-mcp-server"];
      };

      repomix = {
        command = npx;
        args = ["-y" "repomix" "--mcp"];
      };

      # ripgrep = {
      # command = npx;
      # args = ["-y" "mcp-ripgrep@latest"];
      # };

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

      postgres = {
        command = "${pkgs.podman}/bin/podman";
        args = [
          "run"
          "-i"
          "--rm"
          "-e"
          "DATABASE_URI"
          "docker.io/crystaldba/postgres-mcp"
          "--access-mode=restricted"
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

      # github = {
      #   command = npx;
      #   args =
      #     envArgs
      #     ++ [
      #       "${pkgs.podman}/bin/podman"
      #       "run"
      #       "-i"
      #       "--rm"
      #       "-e"
      #       "GITHUB_PERSONAL_ACCESS_TOKEN"
      #       "ghcr.io/github/github-mcp-server"
      #     ];
      # };

      context7 = {
        command = npx;
        args = ["-y" "@upstash/context7-mcp"];
      };
    };
    instructions = ''
      Use context7 for library documentation. The shell used on the system is Nushell, not bash, so in commands use ';' instead of the shell '&&', or 'and' instead of the boolean '&&'.
      Use the repomix tool for tasks that aren't just the most basic edits. You have direct file system access, so don't use the "read repomix output" tool. Just read the file directly.
      Prefer reading the entire repomix file over using the "grep repomix output" tool.
      Use tavily to search the web for information. If working with effect, use the effect tool to get proper documentation.
    '';
  in {
    xdg.configFile."github-copilot/global-copilot-instructions.md".text = instructions;

    programs.vscode.profiles.default.userSettings = {
      "github.copilot.chat.codeGeneration.instructions" = [
        {
          text = instructions;
        }
      ];
      "github.copilot.chat.agent.terminal.allowList" = let
        pkg = "(npm|yarn)";
      in {
        "/${pkg} run$/" = true;
        "/${pkg}( run)? build$/" = true;
        "/${pkg}( run)? typecheck$/" = true;
        "/npx tsc --noEmit$/" = true;
      };
    };

    xdg.configFile."Code/User/mcp.json".text = builtins.toJSON {
      servers = lib.mapAttrs (name: value: value // {type = "stdio";}) servers;
    };

    xdg.configFile."github-copilot/mcp.json".text = builtins.toJSON {
      servers = servers;
    };
  });
}
