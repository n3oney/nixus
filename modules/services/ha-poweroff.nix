{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  config.inputs = {
    poweroff.url = "github:n3oney/ha-poweroff";
  };

  options.services.ha-poweroff.enable = lib.mkEnableOption "ha-poweroff";

  config.os.systemd.services.ha-poweroff = lib.mkIf (config.services.ha-poweroff.enable) {
    enable = true;
    description = "Power off my PC remotely.";
    unitConfig = {
      Type = "simple";
      After = "network.target";
    };

    serviceConfig = {
      User = "root";
      ExecStart = lib.getExe inputs.poweroff.packages.${pkgs.system}.default;
    };

    wantedBy = ["multi-user.target"];
  };
}
