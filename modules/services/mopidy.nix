{
  config,
  lib,
  ...
}: {
  options.services.mopidy.enable = lib.mkEnableOption "Mopidy";

  config.os = lib.mkIf config.services.mopidy.enable {
    services.mopidy = {
      enable = true;
      configuration = ''
        [audio]
        output = pulsesink server=127.0.0.1
      '';
    };

    systemd.services.mopidy = {
      after = ["pulseaudio.service"];
      requires = ["pulseaudio.service"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    users.users.mopidy.extraGroups = ["pulse-access"];
  };
}
