{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.kondo.enable = lib.mkEnableOption "Automatic dependency and build artifacts cleanup.";

  config.os = lib.mkIf config.services.kondo.enable {
    systemd.timers.kondo = {
      wantedBy = ["timers.target"];
      partOf = ["kondo.service"];
      timerConfig = {
        Persistent = true;
        OnCalendar = "daily";
        Unit = "kondo.service";
      };
    };

    systemd.services.kondo = {
      script = ''
        set -eu
        ${pkgs.kondo}/bin/kondo -ao 1w /home/neoney/code
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
    };
  };
}
