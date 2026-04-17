{
  pkgs,
  lib,
  config,
  ...
}: {
  config.h = lib.mkIf config.display.enable {
    systemd.services.playerctld = {
      description = "playerctl daemon";
      partOf = ["graphical-session.target"];
      after = ["graphical-session.target"];
      wantedBy = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${pkgs.playerctl}/bin/playerctld";
        Restart = "on-failure";
      };
    };
  };
}
