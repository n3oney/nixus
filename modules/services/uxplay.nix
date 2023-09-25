{
  lib,
  config,
  pkgs,
  osConfig,
  ...
}: {
  options.services.uxplay = {
    enable = lib.mkEnableOption "UxPlay";
  };

  config.os = lib.mkIf config.services.uxplay.enable {
    networking.firewall = {
      allowedTCPPorts = [7100 7000 7001];
      allowedUDPPorts = [7011 6001 6000];
    };

    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    systemd.user.services.uxplay = {
      after = ["graphical-session.target"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
      };
      script = "${pkgs.uxplay}/bin/uxplay -n \"${osConfig.networking.hostName}\" -nh -p";
    };
  };
}
