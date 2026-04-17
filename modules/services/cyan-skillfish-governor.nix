{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.cyan-skillfish-governor;
  tomlFormat = pkgs.formats.toml {};
  configFile = tomlFormat.generate "cyan-skillfish-governor.toml" cfg.settings;
in {
  options.services.cyan-skillfish-governor = {
    enable = lib.mkEnableOption "Cyan Skillfish SMU GPU governor";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.cyan-skillfish-governor-smu;
    };

    settings = lib.mkOption {
      type = tomlFormat.type;
      default = {
        timing = {
          intervals = {
            sample = 500;
            adjust = 200000;
          };
          ramp-rates = {
            normal = 1;
            burst = 50;
          };
          burst-samples = 60;
          down-events = 5;
        };
        gpu-usage = {
          fix-metrics = true;
          method = "busy-flag";
          flush-every = 10;
        };
        gpu.set-method = "smu";
        dbus.enabled = true;
        frequency-thresholds.adjust = 10;
        load-target = {
          upper = 0.80;
          lower = 0.65;
        };
        temperature = {
          throttling = 85;
          throttling_recovery = 75;
        };
        safe-points = [
          {
            frequency = 1000;
            voltage = 700;
          }
          {
            frequency = 1175;
            voltage = 700;
          }
          {
            frequency = 1400;
            voltage = 750;
          }
          {
            frequency = 1600;
            voltage = 800;
          }
          {
            frequency = 1700;
            voltage = 850;
          }
          {
            frequency = 1850;
            voltage = 900;
          }
          {
            frequency = 2000;
            voltage = 950;
          }
        ];
      };
      description = "TOML settings for cyan-skillfish-governor-smu.";
    };
  };

  config = lib.mkIf cfg.enable {
    os = {
      environment.systemPackages = [cfg.package];
      services.dbus.packages = [cfg.package];

      systemd.services.cyan-skillfish-governor-smu = {
        description = "Cyan Skillfish GPU Governor (SMU)";
        wantedBy = ["multi-user.target"];
        after = ["dbus.service"];
        path = [pkgs.util-linux];
        serviceConfig = {
          ExecStart = "${cfg.package}/bin/cyan-skillfish-governor-smu ${configFile}";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
  };
}
