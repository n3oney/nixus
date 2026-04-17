{
  pkgs,
  config,
  lib,
  inputs,
  hmConfig,
  ...
}: let
  jsonFormat = pkgs.formats.json {};
  effectPatterns = import ../effect-patterns-skills.nix {inherit pkgs lib inputs;};
  skills = lib.genAttrs effectPatterns.skillDirs (name: "${effectPatterns.drv}/${name}");
in {
  options.programs.claude-code = {
    enable = lib.mkEnableOption "claude-code";

    mcpServers = lib.mkOption {
      type = lib.types.attrsOf jsonFormat.type;
      default = {};
      description = "MCP servers to merge into ~/.claude.json via activation script";
    };

    remoteControl = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of directories in which to run `claude remote-control` as user services.";
    };
  };

  config = lib.mkIf config.programs.claude-code.enable {
    impermanence.userDirs = [
      ".claude"
      ".config/claude"
      ".cache/claude"
    ];

    impermanence.userFiles = [".claude.json"];

    hm.systemd.user.services = lib.mkIf (config.programs.claude-code.remoteControl != []) (
      lib.listToAttrs (lib.imap0 (i: dir:
        lib.nameValuePair "claude-remote-control-${toString i}" {
          Unit.Description = "Claude remote control in ${dir}";
          Install.WantedBy = ["default.target"];
          Service = {
            ExecStart = "${lib.getExe pkgs.bash} -lc '${lib.getExe hmConfig.programs.claude-code.package} remote-control --name %H:${dir}'";
            WorkingDirectory = dir;
            Restart = "on-failure";
            RestartSec = 5;
          };
        })
      config.programs.claude-code.remoteControl)
    );

    hm = {
      home.packages = [pkgs.sox];

      home.activation.claudeMcpServers = let
        mcpConfigFile = jsonFormat.generate "claude-mcp-servers.json" {
          mcpServers = config.programs.claude-code.mcpServers;
        };
        jq = lib.getExe pkgs.jq;
      in
        lib.mkIf (config.programs.claude-code.mcpServers != {}) (
          hmConfig.lib.dag.entryAfter ["writeBoundary"] ''
            claude_json="$HOME/.claude.json"
            if [ -f "$claude_json" ]; then
              existing=$(cat "$claude_json")
              merged=$(printf '%s' "''${existing:-"{}"}" | ${jq} -s '.[0] * .[1]' - ${mcpConfigFile})
              printf '%s\n' "$merged" > "$claude_json"
            else
              cp ${mcpConfigFile} "$claude_json"
            fi
          ''
        );

      programs.claude-code = {
        enable = true;
        # Patch the /buddy salt so the companion rolls as a legendary cat.
        # See https://gist.github.com/rinnathecat/0c554c10193b3b8dfac0be338c3d51ee
        package = inputs.nix-ai-tools.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;

        inherit skills;

        settings = {
          voiceEnabled = true;
          theme = "dark";
          permissions = {
            allow = [
              "mcp__lsp"
              "mcp__effect"
              "mcp__context7"
              "mcp__nx"
              "mcp__tavily"
              "mcp__repomix"
              "mcp__github__get_me"
              "mcp__github__get_commit"
              "mcp__github__get_file_contents"
              "mcp__github__get_label"
              "mcp__github__get_latest_release"
              "mcp__github__get_release_by_tag"
              "mcp__github__get_tag"
              "mcp__github__get_team_members"
              "mcp__github__get_teams"
              "mcp__github__issue_read"
              "mcp__github__pull_request_read"
              "mcp__github__list_branches"
              "mcp__github__list_commits"
              "mcp__github__list_issue_types"
              "mcp__github__list_issues"
              "mcp__github__list_pull_requests"
              "mcp__github__list_releases"
              "mcp__github__list_tags"
              "mcp__github__search_code"
              "mcp__github__search_issues"
              "mcp__github__search_pull_requests"
              "mcp__github__search_repositories"
              "mcp__github__search_users"
              "mcp__linear__get_attachment"
              "mcp__linear__get_diff"
              "mcp__linear__get_diff_threads"
              "mcp__linear__get_document"
              "mcp__linear__get_initiative"
              "mcp__linear__get_issue"
              "mcp__linear__get_issue_status"
              "mcp__linear__get_milestone"
              "mcp__linear__get_project"
              "mcp__linear__get_status_updates"
              "mcp__linear__get_team"
              "mcp__linear__get_user"
              "mcp__linear__list_comments"
              "mcp__linear__list_customers"
              "mcp__linear__list_cycles"
              "mcp__linear__list_diffs"
              "mcp__linear__list_documents"
              "mcp__linear__list_initiatives"
              "mcp__linear__list_issue_labels"
              "mcp__linear__list_issue_statuses"
              "mcp__linear__list_issues"
              "mcp__linear__list_milestones"
              "mcp__linear__list_project_labels"
              "mcp__linear__list_projects"
              "mcp__linear__list_teams"
              "mcp__linear__list_users"
              "mcp__linear__search_documentation"
              "mcp__linear__extract_images"
              "Bash(jj log:*)"
              "Bash(jj diff:*)"
              "Bash(jj st:*)"
              "WebSearch"
              "WebFetch"
            ];
            ask = ["mcp__postgresMutable"];
          };
        };
      };
    };
  };
}
