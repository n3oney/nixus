{
  # pkgs,
  osConfig,
  # lib,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  os = {
    boot.binfmt.emulatedSystems = ["aarch64-linux"];

    environment.etc."libinput/local-overrides.quirks".text = ''
      [Never Debounce]
      MatchUdevType=mouse
      ModelBouncingKeys=1
    '';
    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };

    networking = {
      hostName = "miko";
      networkmanager.enable = true;
      interfaces.eno1.wakeOnLan.enable = true;
      firewall.allowedTCPPorts = [2115];
      nameservers = [
        "192.168.1.4"
      ];
    };

    services.journald.extraConfig = "Storage=volatile";

    systemd.services.NetworkManager-wait-online.enable = false;

    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      extraConfig.pipewire."10-remote-audio" = {
        "context.modules" = [
          {
            name = "libpipewire-module-zeroconf-discover";
            args = {};
          }
        ];
      };
    };

    services.avahi.enable = true;

    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    users.users.neoney.openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
    ];

    /*
      fileSystems."/data" = {
      device = "/dev/sdb1";
      fsType = "ntfs3";
      options = ["uid=${toString osConfig.users.users.neoney.uid}" "gid=${toString osConfig.users.users.neoney.uid}"];
    };
    */

    time.timeZone = "Europe/Warsaw";
  };

  os.system.stateVersion = "22.11";
  hm.home.stateVersion = "22.11";
}
