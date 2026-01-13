{
  # osConfig,
  pkgs,
  lib,
  inputs,
  ...
}: {
  osModules = [
    ./hardware-configuration.nix
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nixos-hardware.nixosModules.minisforum-v3
  ];

  impermanence.systemDirs = ["/etc/NetworkManager"];

  os = {
    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    boot.plymouth = {
      enable = true;
      theme = "rings";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = ["rings"];
        })
      ];
    };

    # Silent boot
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];

    networking = {
      hostName = "prism";
      wireless = {
        enable = true;
        # iwd.enable = true;
      };
      networkmanager = {
        enable = true;
        # wifi.backend = "iwd";
        plugins = lib.mkForce [];
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
      wireplumber.extraConfig."10-alsa-soft-mixer" = {
        "monitor.alsa.rules" = [
          {
            matches = [{ "device.name" = "alsa_card.pci-0000_c4_00.6"; }];
            actions.update-props."api.alsa.soft-mixer" = true;
          }
          {
            matches = [
              { "device.name" = "~alsa_card.*"; "node.name" = "~alsa_input.*"; }
            ];
            actions.update-props."api.alsa.soft-mixer" = false;
          }
        ];
      };
    };

    services.tailscale.enable = true;

    hardware.graphics.enable32Bit = true;

    users.users = let
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM1855fHjbeSW54ganm9X4PKuzAUHBm8Hb78TPZE3XjoAAAABHNzaDo= yubikey_5c_nano_2025"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

    time.timeZone = "Europe/Warsaw";

    system.stateVersion = "24.11";
  };

  fingerprint.enable = true;

  hm.home.stateVersion = "24.11";
}
