{
  systemType = "aarch64-linux";

  system = { pkgs, config, lib, ... }: {
    imports = [ ./hardware-configuration.nix ];

    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "cryn";
      networkmanager.enable = true;
      firewall.allowedTCPPorts = [21];
      nameservers = [ "1.1.1.1" "1.0.0.1" ];
      defaultGateway = "10.0.0.1";
      interfaces.eth0 = {
        ipv4.addresses = [{
	  address = "10.0.0.14";
	  prefixLength = 24;
	}];
      };
    };

    users.users.neoney.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/0tMfBBa3Mzp5WvUHKW5aniB3aGTB+Tm0DJ35kbu/QkyGnXwklEZsBIaE1T6v8YzhFPJCxoocvgsK59NAMpx672rHZ/cZtuuVSiEz0hxs+6lEgh3+0rUYMC4h6F+4RCHI01jDfiNyGNPGIsPBlYEY586nC3SlZmTbm3+PnN4d8yd7yyqUeHUP9OjyKqiErbuvGrBtURExwfHKLcaDySrvL13dptc73Rh+B+TxgZ9wYN2OGy8KDXEcpWabQp6hq5Y+ktQ+r0R0Ae1qYT1DZhVK/+S7NJG5z5o5rbuGGy3+O4ssiW/Sy39NBSJZCbaUNuZobJXpBJEqwDDSRDxdKKv3uLFo4/X54Ilvnk96zzKLORxYhNDLUUhVnRlmym2dM3NPowC9Xd0mbHBajByTSEVWSXLWMDPEBajMz1Xel/+LQFj5Hcb6a3sMKZrjDV1HtY3d7n9DOZvzCElV7Ymik8EC2E+QORnQtx+hC0iJn3cDVcsDeJ1QOeZToobOT1M7Lts5etueE1puszJIu7oZIsKXHPrun/dFS/8tdk8+5T0OLBgObwF16FiHPsLFMQx1tvDuU9P9jdwO46vHPUN3AksPbF4S/N0wyMdsqcqA5BZujMYSBUJPCBQnE5Cmju7YHGN58Fg5QBwi44HprJOZCmiQJZGz6qgPuoKD8cOu5oZfJQ== openpgp:0xAFD6D076"
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDeRbPUZZN5JaUiUTKckHr49P9dk5apVC21dpaHAwfWwXllB+OerKE0n9fmmYO/RWEbsL6b5s7lU2HGNwzp7ZMXSuzdhL7eZd1I9J2uy4sWpUmbiV4KxtI6qFTrMdKQ8prr6LZIeL9oV32B8UN178p/tFtoNRh9SkYR0b836OMXqN6hlZcS59msDvyIbF96SQM4MBYpRQKnCKasa8Jnamqnt+oJoLA8OYEwnn1P1Qxqnx+UFlImL78QkAK/ymvgm05k2LpF9JoB1kTaWFS09+ShoPu/vYJ2U7NrZusZcfTFi+DvkF+64ikl8SdzoMbN0CXNNbF2rxiwt98+5bD7l8ne4MwTqqbP4ZI3KlRzjF35gVmtROAoGl69OXl3fPJ4S3MofQBx4eVHDdprJODni6ZQqne/UICshJpQ+VrnTz5vR+ZQHjO/rROHQDTYnyG7MpQ9RmHl0+80765TFuBnpGH0Oh0RpWXB1tsoV8WsK324IchNn7e/3/Os2J0luvMXbN8= neoney@nixuspc"
    ];

    services.openssh.enable = true;

    system.stateVersion = "23.11";
  };

  home = _: {
    home.stateVersion = "23.11";
  };
}
