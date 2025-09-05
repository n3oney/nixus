{
  config,
  lib,
  pkgs,
  inputs,
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
        args = ["-y" "effect-mcp@0.1.10"];
        autoApprove = ["get_effect_doc" "effect_doc_search"];
      };

      git = {
        command = npx;
        args = ["-y" "@cyanheads/git-mcp-server"];
        autoApprove = ["git_add" "git_status" "git_set_working_dir" "git_status" "git_diff" "git_log" "git_push"];
      };

      repomix = {
        command = npx;
        args = ["-y" "repomix" "--mcp"];
        autoApprove = ["grep_repomix_output" "pack_codebase"];
      };

      # ripgrep = {
      # command = npx;
      # args = ["-y" "mcp-ripgrep@latest"];
      # };

      axiom = {
        autoApprove = ["listDatasets" "queryApl"];
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

      postgresReadOnly = {
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

      postgresMutable = {
        command = "${pkgs.podman}/bin/podman";
        args = [
          "run"
          "-i"
          "--rm"
          "-e"
          "DATABASE_URI"
          "docker.io/crystaldba/postgres-mcp"
          "--access-mode=unrestricted"
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
        autoApprove = ["tavily-search" "tavily-extract"];
      };

      github = {
        command = npx;
        autoApprove = ["list_issues" "search_issues" "get_pull_request_diff" "get_issue"];
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
        autoApprove = ["resolve-library-id" "get-library-docs"];
      };
    };
    instructions = ''
      Use context7 for library documentation. The shell used on the system is Nushell, not bash, so in commands use ';' instead of the shell '&&', or 'and' instead of the boolean '&&'.
      Use the repomix tool for tasks that aren't just the most basic edits. You have direct file system access, so don't use the "read repomix output" tool. Just read the file directly.
      Prefer reading the entire repomix file over using the "grep repomix output" tool.
      Use tavily to search the web for information. If working with effect, use the effect tool to get proper documentation.
      Prefer using the postgresReadOnly tool if possible, as it's much faster. Only use the postgresMutable tool if the query will change data. The tools access the same database, so use the postgresMutable ONLY when mutating data. Even when verifying if a mutation done with postgresMutable worked, use postgresReadOnly.
      Do not tackle tasks you were not asked to do without asking for confirmation. For example, if you implement a new feature, and then run typechecks to test if it's correct, do not go out of your way to fix other type errors.
      Do not hallucinate library usages. You have the tools for documentation for a reason. Use the tools, it doesn't cost you anything, and you won't look like a fool on drugs hallucinating libraries.
    '';
  in {
    xdg.configFile."github-copilot/global-copilot-instructions.md".text = instructions;

    home.activation = let
      text = pkgs.writeText "instructions" instructions;
    in {
      cline-instructions = inputs.home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
        run mkdir -p /home/neoney/Documents/Cline/Rules
        run rm /home/neoney/Documents/Cline/Rules/global-instructions.md || true
        run cp ${text} /home/neoney/Documents/Cline/Rules/global-instructions.md
      '';
    };

    /*
    home.file."Documents/Cline/Rules/global-instructions.md" = {
      text = instructions;
      onChange = ''
        cp /home/neoney/Documents/Cline/global-instructions.md /home/neoney/Documents/Cline/01-global-instructions.md
      '';
      recursive = true;
    };
    */

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

    xdg.configFile."Code/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json".text = builtins.toJSON {
      mcpServers = lib.mapAttrs (name: value:
        value
        // {
          disabled = false;
        })
      servers;
    };

    xdg.configFile."Code/User/mcp.json".text = builtins.toJSON {
      servers = lib.mapAttrs (name: value: value // {type = "stdio";}) servers;
    };

    programs.zed-editor.userSettings.context_servers = lib.mapAttrs (name: value:
      value
      // {
        source = "custom";
        enabled = true;
        env = {};
      })
    servers;

    xdg.configFile."github-copilot/mcp.json".text = builtins.toJSON {
      servers = servers;
    };
  });
}
