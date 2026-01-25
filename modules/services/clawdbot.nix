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
    agents = {
      defaults = {
        workspace = "/var/lib/clawdbot/workspace";
        model.primary = "zai/glm-4.7";
      };
    };
    channels = {
      telegram = {
        enabled = true;
        tokenFile = osConfig.age.secrets.clawdbot_telegram.path;
        allowFrom = [ 951651146 ];
        groups."*".requireMention = true;
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
          ExecStartPre = ''
            ${pkgs.coreutils}/bin/mkdir -p /var/lib/clawdbot/workspace
            ${pkgs.coreutils}/bin/cp -r ${documents}/* /var/lib/clawdbot/workspace/
          '';
          ExecStart = "${inputs.nix-clawdbot.packages.${pkgs.system}.clawdbot-gateway}/bin/clawdbot --config ${configFile}";
          Restart = "on-failure";
          RestartSec = "10s";
        };
      };
    };
  };
}
