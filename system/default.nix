{
  pkgs,
  inputs,
  vars,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [
    inputs.hyprland.overlays.default
    inputs.hyprpaper.overlays.default
    inputs.hyprcontrib.overlays.default
    inputs.hyprpicker.overlays.default
    inputs.eww.overlays.default
    inputs.rust-overlay.overlays.default
    inputs.anyrun.overlay
    inputs.shadower.overlay
    (import ../pkgs/overlays)
  ];

  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ./packages.nix
    ./fonts.nix
    ./login.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixuspc";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable sound.
  sound.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

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

  home-manager.users.neoney = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.stateVersion = "22.11";
  };

  users.users.neoney = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "networkmanager"];
    packages = [];
  };

  nix = {
    package = pkgs.nixFlakes;
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      experimental-features = ["nix-command" "flakes"];
      trusted-users = [
        "root"
        "neoney"
      ];
    };
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };

  programs.fish.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  systemd.services.poweroff = {
    enable = true;
    description = "Power off my PC remotely.";
    unitConfig = {
      Type = "simple";
      After = "network.target";
    };

    serviceConfig = {
      User = "root";
      ExecStart = lib.getExe inputs.poweroff.packages.x86_64-linux.poweroff;
    };

    wantedBy = ["multi-user.target"];
  };

  hardware.gpgSmartcards.enable = true;
  services.dbus.packages = [pkgs.gcr];

  services.avahi.enable = true;

  home-manager.extraSpecialArgs = {
    inherit inputs vars;
  };

  services.gnome.gnome-keyring.enable = true;

  security.pam.services.gtklock = {};
  services.physlock = {
    enable = true;
    allowAnyUser = true;

    lockOn = {
      suspend = false;
      hibernate = false;
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  programs.gamemode.enable = true;

  system.stateVersion = "22.11";
}
