{
  lib,
  config,
  osConfig,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.services.clawdbot;
  
  # Generate config file
  clawdbotConfig = {
    gateway = {
      mode = "local";
      port = 18789;
      bind = "loopback";
      tailscale = {
        mode = "off";
        resetOnExit = false;
      };
    };
    agents = {
      defaults = {
        workspace = "/var/lib/clawdbot/workspace";
        model.primary = "anthropic/claude-sonnet-4-5";
        maxConcurrent = 4;
        subagents.maxConcurrent = 8;
        models = {
          "anthropic/claude-sonnet-4-5" = {
            alias = "sonnet";
          };
          "zai/glm-4.7" = {
            alias = "glm";
          };
        };
      };
    };
    commands = {
      native = "auto";
      nativeSkills = "auto";
    };
    channels = {
      telegram = {
        enabled = true;
        dmPolicy = "pairing";
        tokenFile = osConfig.age.secrets.clawdbot_telegram.path;
        allowFrom = [ 951651146 ];
        groups."*".requireMention = true;
        groupPolicy = "allowlist";
        streamMode = "partial";
      };
    };
    messages = {
      ackReactionScope = "group-mentions";
    };
    plugins = {
      entries = {
        telegram = {
          enabled = true;
        };
      };
    };
    auth = {
      profiles = {
        "anthropic:default" = {
          provider = "anthropic";
          mode = "token";
        };
      };
    };
    skills = {
      install = {
        nodeManager = "npm";
      };
    };
    hooks = {
      internal = {
        enabled = true;
        entries = {
          "boot-md" = {
            enabled = true;
          };
          "session-memory" = {
            enabled = true;
          };
        };
      };
    };
  };
  
  configFile = pkgs.writeText "clawdbot.json" (builtins.toJSON clawdbotConfig);
  
  # Document files
  documents = pkgs.runCommand "clawdbot-documents" {} ''
    mkdir -p $out
    cat > $out/AGENTS.md << 'EOF'
# AGENTS.md

Principles:
- Be concise in chat; write long output to files.
- Treat this workspace as the system of record.
- Prefer explicit, deterministic changes.
- NEVER send any message without explicit user confirmation.

# Time Awareness
- Current year is 2026
- When scheduling cron jobs or any time-based tasks, always verify the year is correct
- Today's date can be confirmed by checking system time if uncertain
EOF

    cat > $out/SOUL.md << 'EOF'
# SOUL.md

Clawdbot exists to do useful work reliably with minimal friction.
EOF

    cat > $out/TOOLS.md << 'EOF'
# TOOLS.md

Plugin report appended below.
EOF
  '';
in {
  options.services.clawdbot.enable = lib.mkEnableOption "Clawdbot AI gateway";

  config = lib.mkIf cfg.enable {
    os = {
      users.users.clawdbot = {
        isSystemUser = true;
        group = "clawdbot";
        home = "/var/lib/clawdbot";
        createHome = true;
      };

      users.groups.clawdbot = {};

      systemd.services.clawdbot = {
        description = "Clawdbot AI Gateway";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        serviceConfig = {
          Type = "simple";
          User = "clawdbot";
          Group = "clawdbot";
          WorkingDirectory = "/var/lib/clawdbot";
          EnvironmentFile = osConfig.age.secrets.clawdbot_zai.path;
          Environment = [
            "CLAWDBOT_CONFIG_PATH=${configFile}"
            "CLAWDBOT_STATE_DIR=/var/lib/clawdbot"
            "CLAWDBOT_NIX_MODE=1"
          ];
          ExecStartPre = [
            "${pkgs.coreutils}/bin/mkdir -p /var/lib/clawdbot/workspace"
            "${pkgs.coreutils}/bin/mkdir -p /var/lib/clawdbot/agents/main/sessions"
            "${pkgs.coreutils}/bin/mkdir -p /var/lib/clawdbot/credentials"
            "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/cp -rf ${documents}/* /var/lib/clawdbot/workspace/ || true'"
          ];
          ExecStart = "${inputs.nix-clawdbot.packages.${pkgs.system}.clawdbot-gateway}/bin/clawdbot gateway";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
