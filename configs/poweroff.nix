{
  inputs = {
    poweroff.url = "github:n3oney/ha-poweroff";
  };

  system = {
    lib,
    inputs,
    pkgs,
    ...
  }: {
    systemd.services.ha-poweroff = {
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
  };
}
