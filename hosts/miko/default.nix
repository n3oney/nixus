{
  # pkgs,
  osConfig,
  # lib,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
  ];

  impermanence.systemDirs = ["/etc/NetworkManager"];

  windowsBoot = {
    enable = true;
    bootEntry = "0037";
  };

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
      # grub.enable = true;
      efi.canTouchEfiVariables = true;
    };

    networking = {
      hostName = "miko";
      networkmanager.enable = true;
      interfaces.enp6s0.wakeOnLan.enable = true;
      firewall.allowedTCPPorts = [2115];
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    services.journald.extraConfig = "Storage=volatile";

    systemd.services.NetworkManager-wait-online.enable = false;

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
      wireplumber.extraConfig."51-audio-defaults"."monitor.alsa.rules" = [
        {
          matches = [{"node.name" = "alsa_output.pci-0000_0c_00.4.iec958-stereo";}];
          actions.update-props."node.disabled" = true;
        }
        {
          matches = [{"node.name" = "alsa_input.usb-Sunplus_IT_Co_HD_720P_webcam_AN20200706001-02.mono-fallback";}];
          actions.update-props."node.disabled" = true;
        }
        {
          matches = [{"node.name" = "alsa_input.usb-SM900_Microphon_SM900_Microphone_20190703-00.mono-fallback";}];
          actions.update-props."priority.session" = 2000;
        }
      ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };

    hardware.graphics.enable32Bit = true;

    users.users.neoney.openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM1855fHjbeSW54ganm9X4PKuzAUHBm8Hb78TPZE3XjoAAAABHNzaDo= yubikey_5c_nano_2025"
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
