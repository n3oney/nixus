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
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # Remote audio support
    environment.etc."pipewire/pipewire.conf.d/zeroconf.conf" = {
      mode = "0444";
      text = ''
        context.modules = [
          {
            name = libpipewire-module-zeroconf-discover
            args = {}
          }
        ]
      '';
    };
    services.avahi.enable = true;

    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    users.users.neoney.openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/0tMfBBa3Mzp5WvUHKW5aniB3aGTB+Tm0DJ35kbu/QkyGnXwklEZsBIaE1T6v8YzhFPJCxoocvgsK59NAMpx672rHZ/cZtuuVSiEz0hxs+6lEgh3+0rUYMC4h6F+4RCHI01jDfiNyGNPGIsPBlYEY586nC3SlZmTbm3+PnN4d8yd7yyqUeHUP9OjyKqiErbuvGrBtURExwfHKLcaDySrvL13dptc73Rh+B+TxgZ9wYN2OGy8KDXEcpWabQp6hq5Y+ktQ+r0R0Ae1qYT1DZhVK/+S7NJG5z5o5rbuGGy3+O4ssiW/Sy39NBSJZCbaUNuZobJXpBJEqwDDSRDxdKKv3uLFo4/X54Ilvnk96zzKLORxYhNDLUUhVnRlmym2dM3NPowC9Xd0mbHBajByTSEVWSXLWMDPEBajMz1Xel/+LQFj5Hcb6a3sMKZrjDV1HtY3d7n9DOZvzCElV7Ymik8EC2E+QORnQtx+hC0iJn3cDVcsDeJ1QOeZToobOT1M7Lts5etueE1puszJIu7oZIsKXHPrun/dFS/8tdk8+5T0OLBgObwF16FiHPsLFMQx1tvDuU9P9jdwO46vHPUN3AksPbF4S/N0wyMdsqcqA5BZujMYSBUJPCBQnE5Cmju7YHGN58Fg5QBwi44HprJOZCmiQJZGz6qgPuoKD8cOu5oZfJQ== openpgp:0xAFD6D076"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILy82EObnwVhhehQApdzF/rXGWnkts8+yWcKyVcaWUGp root@max"
    ];

    fileSystems."/data" = {
      device = "/dev/sdb1";
      fsType = "ntfs3";
      options = ["uid=${toString osConfig.users.users.neoney.uid}" "gid=${toString osConfig.users.users.neoney.uid}"];
    };

    time.timeZone = "Europe/Warsaw";
  };

  os.system.stateVersion = "22.11";
  hm.home.stateVersion = "22.11";
}
