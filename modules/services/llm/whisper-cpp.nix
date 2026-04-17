{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.whisper-cpp;
in {
  options.services.whisper-cpp = {
    enable = lib.mkEnableOption "whisper.cpp server (Vulkan)";

    model = lib.mkOption {
      type = lib.types.path;
      description = ''
        Path to the GGML model file (download from
        https://huggingface.co/ggerganov/whisper.cpp).
      '';
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 10301;
    };

    language = lib.mkOption {
      type = lib.types.str;
      default = "auto";
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
    systemd.services.whisper-cpp = {
      description = "whisper.cpp OpenAI-compatible server (Vulkan)";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];

      # Server shells out to `ffmpeg` when --convert is set, so it must be on PATH.
      path = [pkgs.ffmpeg];

      environment = {
        AMD_VULKAN_ICD = "RADV";
        XDG_CACHE_HOME = "%S/whisper-cpp/cache";
      };

      serviceConfig = {
        ExecStart = lib.concatStringsSep " " ([
            "${pkgs.whisper-cpp-vulkan}/bin/whisper-server"
            "--model ${cfg.model}"
            "--host ${cfg.host}"
            "--port ${toString cfg.port}"
            "--language ${cfg.language}"
            "--inference-path /v1/audio/transcriptions"
            "--convert"
          ]
          ++ cfg.extraArgs);
        DynamicUser = true;
        StateDirectory = "whisper-cpp";
        # --convert writes temp WAVs to CWD; point it at the state dir.
        WorkingDirectory = "%S/whisper-cpp";
        OOMScoreAdjust = -500;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.port];
  };
}
