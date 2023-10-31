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
      group = config.services.arr.group.name;
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
        networking.firewall.allowedUDPPorts = [53 51370];
        networking.firewall.allowedTCPPorts = [9091 51370];

        services.openvpn.servers = {
          airvpn.config = "config /root/nixos/openvpn/airvpn.ovpn";
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
            # ratio-limit = 1.1;
            # ratio-limit-enabled = true;
            # script-torrent-done-seeding-enabled = true;
            # script-torrent-done-seeding-filename = pkgs.writeShellScript "done-seeding.sh" ''
            # ${pkgs.transmission}/bin/transmission-remote --torrent $TR_TORRENT_ID --remove-and-delete
            # '';
            peer-port = 51370;
          };
        };

        systemd.services.transmission.serviceConfig = {
          RootDirectoryStartOnly = lib.mkForce false;
          RootDirectory = lib.mkForce "";
        };

        systemd.services.transmission.after = ["openvpn-airvpn.service"];
        systemd.services.transmission.requires = ["openvpn-airvpn.service"];

        system.stateVersion = "23.11";
      };
    };
  };
}
