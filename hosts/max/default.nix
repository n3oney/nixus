{...}: {
  osModules = [./hardware-configuration.nix];

  os = {
    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.graceful = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "max";
      networkmanager = {
        enable = true;
      };
      interfaces.enp1s0.ipv4.addresses = [
        {
          address = "192.168.1.4";
          prefixLength = 24;
        }
      ];
      defaultGateway = "192.168.1.1";
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users = let
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/0tMfBBa3Mzp5WvUHKW5aniB3aGTB+Tm0DJ35kbu/QkyGnXwklEZsBIaE1T6v8YzhFPJCxoocvgsK59NAMpx672rHZ/cZtuuVSiEz0hxs+6lEgh3+0rUYMC4h6F+4RCHI01jDfiNyGNPGIsPBlYEY586nC3SlZmTbm3+PnN4d8yd7yyqUeHUP9OjyKqiErbuvGrBtURExwfHKLcaDySrvL13dptc73Rh+B+TxgZ9wYN2OGy8KDXEcpWabQp6hq5Y+ktQ+r0R0Ae1qYT1DZhVK/+S7NJG5z5o5rbuGGy3+O4ssiW/Sy39NBSJZCbaUNuZobJXpBJEqwDDSRDxdKKv3uLFo4/X54Ilvnk96zzKLORxYhNDLUUhVnRlmym2dM3NPowC9Xd0mbHBajByTSEVWSXLWMDPEBajMz1Xel/+LQFj5Hcb6a3sMKZrjDV1HtY3d7n9DOZvzCElV7Ymik8EC2E+QORnQtx+hC0iJn3cDVcsDeJ1QOeZToobOT1M7Lts5etueE1puszJIu7oZIsKXHPrun/dFS/8tdk8+5T0OLBgObwF16FiHPsLFMQx1tvDuU9P9jdwO46vHPUN3AksPbF4S/N0wyMdsqcqA5BZujMYSBUJPCBQnE5Cmju7YHGN58Fg5QBwi44HprJOZCmiQJZGz6qgPuoKD8cOu5oZfJQ== openpgp:0xAFD6D076"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

    services.avahi.ipv6 = false;

    hardware.pulseaudio = {
      enable = true;
      zeroconf.publish.enable = true;
      tcp = {
        enable = true;
        anonymousClients.allowedIpRanges = ["127.0.0.1" "192.168.1.5"];
      };
      systemWide = true;
    };

    networking.firewall.allowedTCPPorts = [4713];
    networking.firewall.allowedUDPPorts = [4713];

    time.timeZone = "Europe/Warsaw";

    system.stateVersion = "23.05";
  };

  hm.home.stateVersion = "23.05";
}
