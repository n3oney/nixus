{
  systemType = "x86_64-linux";

  system = {
    pkgs,
    config,
    lib,
    ...
  }: {
    imports = [./hardware-configuration.nix];

    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };

    networking = {
      hostName = "zia";
      wireless = {
        enable = false;
        iwd.enable = true;
      };
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
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

    # AirPlay support
    services.avahi.enable = true;
    environment.etc."pipewire/pipewire.conf.d/airplay.conf" = {
      mode = "0444";
      text = ''
        context.modules = [
          {
            name = libpipewire-module-raop-discover
            args = {}
          }
        ]
      '';
    };

    hardware.opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };

    system.stateVersion = "23.05";
  };

  home = _: {
    home.stateVersion = "23.05";
  };
}
