{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.llama-cpp;
  llama = inputs.llama-cpp.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;
in {
  options.services.llama-cpp = {
    enable = lib.mkEnableOption "llama.cpp server (Vulkan)";

    model = lib.mkOption {
      type = lib.types.path;
      description = "Path to the GGUF model file.";
    };

    mmproj = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional multimodal projector GGUF (audio/vision).";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 11434;
    };

    contextSize = lib.mkOption {
      type = lib.types.int;
      default = 16384;
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config.os = lib.mkIf cfg.enable {
    systemd.services.llama-cpp = {
      description = "llama.cpp OpenAI-compatible server (Vulkan)";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      environment = {
        AMD_VULKAN_ICD = "RADV";
        XDG_CACHE_HOME = "%S/llama-cpp/cache";
      };

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " ([
            "${llama}/bin/llama-server"
            "--model ${cfg.model}"
            "--host ${cfg.host}"
            "--port ${toString cfg.port}"
            "--ctx-size ${toString cfg.contextSize}"
            "-ngl 99"
            "--flash-attn on"
            "--no-prefill-assistant"
            "--cache-type-k q8_0"
            "--cache-type-v q8_0"
            "--mlock"
            "--jinja"
            "--parallel 1"
            "--cache-ram 2048"
            "--ctx-checkpoints 16"
            # "--checkpoint-every-n-tokens 4096"
            "--cache-reuse 256"
            ''--chat-template-kwargs {\"enable_thinking\":false}''
            "--temp 0.7"
            "--top-p 0.8"
            "--top-k 20"
            "--min-p 0.0"
            "--presence-penalty 1.5"
            "--repeat-penalty 1.0"
          ]
          ++ lib.optional (cfg.mmproj != null) "--mmproj ${cfg.mmproj}"
          ++ cfg.extraArgs);
        DynamicUser = true;
        StateDirectory = "llama-cpp";
        OOMScoreAdjust = -1000;
        LimitMEMLOCK = "infinity";
        AmbientCapabilities = ["CAP_IPC_LOCK"];
        CapabilityBoundingSet = ["CAP_IPC_LOCK"];
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
