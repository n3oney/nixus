{
  lib,
  inputs,
  pkgs,
  config,
  ...
}: let
  cfg = config.display;
  wallpaper = ../../../wallpapers/ios13.jpg;
  awwwPkg = inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.default;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    hm.home.packages = [awwwPkg];

    hm.systemd.user.services = {
      awww = {
        Unit = {
          Description = "Animated wallpaper daemon";
          PartOf = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${awwwPkg}/bin/awww-daemon";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      awww-wallpaper = {
        Unit = {
          Description = "Set wallpaper via awww";
          After = ["awww.service"];
          Requires = ["awww.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
          ExecStart = "${awwwPkg}/bin/awww img ${wallpaper} --transition-type fade";
          RemainAfterExit = true;
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
  };
}
