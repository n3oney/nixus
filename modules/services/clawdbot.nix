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
        heartbeat = {
          every = "30m";
          target = "last";
        };
      };
    };
    commands = {
      native = "auto";
      nativeSkills = "auto";
      restart = true;
    };
    channels = {
      telegram = {
        enabled = true;
        dmPolicy = "pairing";
        tokenFile = osConfig.age.secrets.clawdbot_telegram.path;
        allowFrom = [ 951651146 7844967025 ];
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

---

# Cron - Reminders and Scheduled Tasks

## Basics

Cron is used for precise task scheduling. There are two main modes:
- **isolated session** - dedicated agent turn, direct delivery
- **main session** - system event in main session, delivered via heartbeat

---

## Isolated Session (RECOMMENDED for reminders)

**When to use:**
- Simple reminders
- Reliable delivery without heartbeat dependency
- Tasks that can work without main session context

**Structure:**
```javascript
{
  "name": "Reminder name",
  "schedule": {"kind": "at", "atMs": "2026-01-25T12:30:00Z"},
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Reminder content",
    "deliver": true,
    "channel": "telegram",     // telegram/webchat/whatsapp/discord/signal
    "to": "-5056149787"        // chat_id/phone/user_id
  },
  "deleteAfterRun": true,      // auto-delete after execution
  "enabled": true
}
```

**Advantages:**
- ✅ Delivers directly to channel (not via heartbeat)
- ✅ Doesn't require `heartbeat.target` configuration
- ✅ Works reliably

---

## Main Session (for contextual tasks)

**When to use:**
- Task requires main session context
- You want the reminder to be part of conversation history
- Heartbeat is properly configured

**Structure:**
```javascript
{
  "name": "Reminder name",
  "schedule": {"kind": "at", "atMs": "2026-01-25T12:30:00Z"},
  "sessionTarget": "main",
  "payload": {
    "kind": "systemEvent",
    "text": "Reminder content"
  },
  "wakeMode": "now",          // immediate heartbeat wake
  "deleteAfterRun": true,
  "enabled": true
}
```

**Wakemode:**
- `"now"` - immediate wake after job execution (for reminders)
- `"next-heartbeat"` - waits for next scheduled heartbeat (default)

---

## Schedule Types

**One-shot (reminder):**
```javascript
"schedule": {"kind": "at", "atMs": "2026-01-25T12:30:00Z"}
```

**Recurring (every X time):**
```javascript
"schedule": {"kind": "every", "everyMs": 3600000}  // every hour
```

**Cron expression:**
```javascript
"schedule": {
  "kind": "cron", 
  "expr": "0 9 * * 1-5",  // 9:00 on weekdays
  "tz": "Europe/Warsaw"   // optional timezone
}
```

---

## Timestamps

**ISO 8601 (preferred):**
- `"2026-01-25T12:30:00Z"` - UTC
- `"2026-01-25T13:30:00+01:00"` - with timezone
- Gateway automatically converts to milliseconds

**Unix timestamp (ms):**
- `1769343420000` - milliseconds since epoch

---

## Important Details

**Auto-delete:**
```javascript
"deleteAfterRun": true  // removes job after successful execution
```

**Always verify timestamp is in the future.**

**Delivery channels:**
- `telegram`: requires chat_id (e.g. `"-5056149787"`)
- `webchat`: requires session/user id
- `whatsapp`: requires phone number
- `discord`: requires channel/user id
- `signal`: requires phone number

---

## Status Commands

**List jobs:**
```javascript
cron.list
```

**Execution history:**
```javascript
cron.runs(jobId, limit)
```

**Remove job:**
```javascript
cron.remove(jobId)
```

---

## Examples

**Reminder in 5 minutes:**
```javascript
{
  "name": "Feed the cat",
  "schedule": {"kind": "at", "atMs": "2026-01-25T12:35:00Z"},
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Reminder: feed the cat",
    "deliver": true,
    "channel": "telegram",
    "to": "-5056149787"
  },
  "deleteAfterRun": true,
  "enabled": true
}
```

**Daily report at 9:00:**
```javascript
{
  "name": "Daily report",
  "schedule": {
    "kind": "cron",
    "expr": "0 9 * * *",
    "tz": "Europe/Warsaw"
  },
  "sessionTarget": "isolated",
  "payload": {
    "kind": "agentTurn",
    "message": "Generate daily report",
    "deliver": true,
    "channel": "telegram",
    "to": "-5056149787"
  },
  "enabled": true
}
```
EOF

    cat > $out/HEARTBEAT.md << 'EOF'
# Heartbeat checklist

- Quick scan: anything urgent or pending?
- If it's daytime, do a lightweight check-in if nothing else is pending.
- If a task is blocked, note what is missing and ask next time.
- If nothing needs attention, reply HEARTBEAT_OK.
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
