{
  pkgs,
  lib,
  config,
  ...
}: {
  config.hm = lib.mkIf config.display.enable {
    systemd.user.services.playerctld = {
      Unit = {
        Description = "playerctl daemon";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.playerctl}/bin/playerctld";
        Restart = "on-failure";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
