{
  inputs = {
    poweroff.url = "/home/neoney/code/poweroff";
  };

  system = {
    lib,
    inputs,
    pkgs,
    ...
  }: {
    systemd.services.poweroff = {
      enable = true;
      description = "Power off my PC remotely.";
      unitConfig = {
        Type = "simple";
        After = "network.target";
      };

      serviceConfig = {
        User = "root";
        ExecStart = lib.getExe inputs.poweroff.packages.${pkgs.system}.poweroff;
      };

      wantedBy = ["multi-user.target"];
    };
  };
}
