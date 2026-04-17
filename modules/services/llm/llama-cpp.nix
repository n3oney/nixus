{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.services.llama-cpp;
  llama = inputs.llama-cpp.packages.${pkgs.stdenv.hostPlatform.system}.vulkan;

  instanceOpts = {name, ...}: {
    options = {
      model = lib.mkOption {
        type = lib.types.path;
        description = "Path to the GGUF model file.";
      };

      mmproj = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Optional multimodal projector GGUF (audio/vision). Chat instances only.";
      };

      vocoder = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = ''
          GGUF vocoder model (e.g. WavTokenizer for OuteTTS).
          When set, the instance runs as a TTS server exposing
          OpenAI-compatible /v1/audio/speech, and the chat-tuned
          sampling defaults are not applied.
        '';
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
  };

  chatArgs = [
    "--ubatch-size 2048"
    "--flash-attn on"
    "--no-prefill-assistant"
    "--cache-type-k q8_0"
    "--cache-type-v q8_0"
    "--jinja"
    "--parallel 1"
    "--cache-ram 2048"
    "--ctx-checkpoints 16"
    "--cache-reuse 256"
    ''--chat-template-kwargs {\"enable_thinking\":false}''
    "--temp 0.7"
    "--top-p 0.8"
    "--top-k 20"
    "--min-p 0.0"
    "--presence-penalty 1.5"
    "--repeat-penalty 1.0"
  ];

  mkUnit = name: icfg: let
    isTts = icfg.vocoder != null;
  in {
    description = "llama.cpp ${
      if isTts
      then "TTS"
      else "chat"
    } server (Vulkan) [${name}]";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];

    environment = {
      AMD_VULKAN_ICD = "RADV";
      XDG_CACHE_HOME = "%S/llama-cpp-${name}/cache";
    };

    serviceConfig = {
      ExecStart = lib.concatStringsSep " " ([
          "${llama}/bin/llama-server"
          "--model ${icfg.model}"
          "--host ${icfg.host}"
          "--port ${toString icfg.port}"
          "--ctx-size ${toString icfg.contextSize}"
          "-ngl 99"
        ]
        ++ lib.optionals (!isTts) chatArgs
        ++ lib.optional isTts "--model-vocoder ${icfg.vocoder}"
        ++ lib.optional (icfg.mmproj != null) "--mmproj ${icfg.mmproj}"
        ++ icfg.extraArgs);
      DynamicUser = true;
      SupplementaryGroups = ["render" "video"];
      StateDirectory = "llama-cpp-${name}";
      OOMScoreAdjust = -1000;
      LimitMEMLOCK = "infinity";
      AmbientCapabilities = ["CAP_IPC_LOCK"];
      CapabilityBoundingSet = ["CAP_IPC_LOCK"];
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
in {
  options.services.llama-cpp = {
    instances = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule instanceOpts);
      default = {};
      description = "Named llama.cpp server instances (chat or TTS).";
    };
  };

  config.os = lib.mkIf (cfg.instances != {}) {
    systemd.services =
      lib.mapAttrs' (
        name: icfg:
          lib.nameValuePair "llama-cpp-${name}" (mkUnit name icfg)
      )
      cfg.instances;

    networking.firewall.allowedTCPPorts =
      lib.concatLists (lib.mapAttrsToList (_: icfg:
        lib.optional icfg.openFirewall icfg.port)
      cfg.instances);
  };
}
