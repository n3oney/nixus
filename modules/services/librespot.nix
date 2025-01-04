{
  config,
  pkgs,
  lib,
  ...
}: {
  options.services.librespot.enable = lib.mkEnableOption "Librespot";

  config.os = lib.mkIf config.services.librespot.enable {
    systemd.services.librespot = {
      after = ["pulseaudio.service"];
      requires = ["pulseaudio.service" "network-online.target"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        User = toString config.os.users.users.librespot.name;
        Group = toString config.os.users.groups.librespot.name;
      };
      wantedBy = ["multi-user.target"];
      script = "${pkgs.librespot}/bin/librespot --name Librespot --enable-oauth -c /var/cache/librespot";
    };

    systemd.tmpfiles.rules = [
      "d /var/cache/librespot 0700 ${toString config.os.users.users.librespot.uid} ${toString config.os.users.groups.librespot.gid}"
    ];

    users.groups.librespot = {};

    users.users.librespot = {
      isSystemUser = true;
      group = "librespot";
      extraGroups = ["pulse-access"];
    };
  };
}
