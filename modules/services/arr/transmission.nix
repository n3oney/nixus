{
  config,
  lib,
  ...
}: let
  containerAddress = "10.0.0.253";
in {
  options.services.arr.transmission.enable = lib.mkEnableOption "transmission" // {default = config.services.arr.enable;};

  config.os = lib.mkIf (config.services.arr.enable && config.services.arr.transmission.enable) {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-transmission"];
      externalInterface = "eth0";
      enableIPv6 = true;
    };

    users.users.transmission = {
      isSystemUser = true;
      group = "transmission";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/transmission/Downloads 0774 transmission ${toString config.services.arr.group.gid}"
    ];

    networking.firewall.allowedUDPPorts = [53];

    containers.transmission = {
      autoStart = true;
      enableTun = true;
      privateNetwork = true;
      hostAddress = containerAddress;
      localAddress = "10.0.0.3";

      forwardPorts = [
        {
          containerPort = 53;
          hostPort = 53;
          protocol = "udp";
        }

        {
          containerPort = 9091;
          hostPort = 9091;
          protocol = "tcp";
        }

        {
          containerPort = 9091;
          hostPort = 9091;
          protocol = "udp";
        }
      ];

      bindMounts = {
        "/var/lib/transmission" = {
          hostPath = "/var/lib/transmission";
          isReadOnly = false;
        };

        "/root/nixos/openvpn" = {
          hostPath = "/root/nixos/openvpn";
          isReadOnly = true;
        };
      };

      config = {pkgs, ...}: {
        networking.firewall.allowedUDPPorts = [53];
        networking.firewall.allowedTCPPorts = [9091];

        services.openvpn.servers = {
          mullvad.config = "config /root/nixos/openvpn/mullvad.conf";
        };

        users.groups."${config.services.arr.group.name}" = {
          inherit (config.services.arr.group) gid;
        };

        services.transmission = {
          enable = true;
          group = config.services.arr.group.name;
          settings = {
            rpc-whitelist-enabled = false;
            rpc-bind-address = "0.0.0.0";
          };
        };

        systemd.services.transmission.after = ["openvpn-mullvad.service"];
        systemd.services.transmission.requires = ["openvpn-mullvad.service"];

        system.stateVersion = "23.11";
      };
    };
  };
}
