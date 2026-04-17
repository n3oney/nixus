{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.programs.quickshell;
in {
  options.programs.quickshell = {
    enable = lib.mkEnableOption "quickshell";
    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
      description = "The package to use for quickshell";
    };
  };

  config.h = lib.mkIf cfg.enable {
    packages = [cfg.package];

    xdg.config.files."quickshell/niri-offscreen-indicator/shell.qml".source = ./niri-offscreen-indicator/shell.qml;

    systemd.services.quickshell-niri-offscreen-indicator = {
      description = "Quickshell Niri Offscreen Indicator";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/quickshell -c niri-offscreen-indicator";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
