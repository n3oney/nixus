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

  config.hm = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    xdg.configFile."quickshell/niri-offscreen-indicator/shell.qml".source = ./niri-offscreen-indicator/shell.qml;

    systemd.user.services.quickshell-niri-offscreen-indicator = {
      Unit = {
        Description = "Quickshell Niri Offscreen Indicator";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/quickshell -c niri-offscreen-indicator";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
}
