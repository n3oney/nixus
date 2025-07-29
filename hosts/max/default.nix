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
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

    services.avahi.ipv6 = false;

    services.pulseaudio = {
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
