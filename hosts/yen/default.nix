_: {
  osModules = [./hardware-configuration.nix];
  os = {
    systemd.services.NetworkManager-wait-online.enable = false;

    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

    networking = {
      hostName = "yen";
      networkmanager.enable = true;
      enableIPv6 = true;
      firewall.allowedTCPPorts = [21];
      nameservers = ["1.1.1.1" "1.0.0.1"];
      defaultGateway = "10.0.0.1";
      interfaces.eth0 = {
        useDHCP = true;
        ipv4.addresses = [
          {
            address = "10.0.0.14";
            prefixLength = 24;
          }
        ];
      };
    };

    users.users = let
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM1855fHjbeSW54ganm9X4PKuzAUHBm8Hb78TPZE3XjoAAAABHNzaDo= yubikey_5c_nano_2025"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEPJbUlKITUdp9smZY6kDCFcZNmbQVzHspvBWup7lwHt github-actions-deploy"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

    services.openssh.enable = true;

    system.stateVersion = "23.05";

    boot.kernel.sysctl."net.core.wmem_max" = 2097152;
  };

  hm.home.stateVersion = "23.05";
}
