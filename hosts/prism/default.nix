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
        wifi.powersave = true;
        plugins = lib.mkForce [];
      };
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    boot.extraModprobeConfig = ''
      # Swap the order: First detected device (HDMI) gets index 1
      # Second detected device (Analog) gets index 0
      options snd_hda_intel index=1,0
    '';

    systemd.services.restore-audio-levels = {
      description = "Unmute and max out speakers on boot";
      wantedBy = ["multi-user.target"];
      after = ["sound.target"];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        # Wait a moment for devices to settle
        ${pkgs.coreutils}/bin/sleep 2

        # Force Card 0 (Analog) Master, Speaker, and Headphone to 100%
        amixer="${pkgs.alsa-utils}/bin/amixer"
        $amixer -c 0 sset Master 100% unmute || true
        $amixer -c 0 sset Speaker 100% unmute || true
        $amixer -c 0 sset Headphone 100% unmute || true
      '';
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

    # Direct PAM configuration for biometric auth
    # Enable fingerprint service
    services.fprintd.enable = true;
    systemd.services.fprintd = {
      wantedBy = ["multi-user.target"];
      serviceConfig.Type = "simple";
    };

    # Direct PAM rules
    security.pam.services = let
      howdy = config.biometricAuth.howdy.package;

      # Biometrics-first: face → fingerprint → password
      # For services without a password prompt UI (sudo, polkit)
      biometricsFirstAuth = {
        howdy = {
          enable = true;
          control = "sufficient";
          modulePath = "${howdy}/lib/security/pam_howdy.so";
          order = 0;
        };
        fprintd = {
          enable = true;
          control = "sufficient";
          modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
          order = 100;
        };
      };

      # Password-first with biometrics: password → fingerprint (as fallback)
      # For login/hyprlock that show a password field
      # Note: Howdy removed - it has a bug with greetd's pam_setcred
      # See: https://github.com/boltgolt/howdy/issues/991
      # gnome_keyring must run BEFORE unix to capture password for auto-unlock
      passwordFirstWithBiometrics = {
        # Capture password for keyring before unix validates
        gnome_keyring = {
          enable = true;
          control = "optional";
          modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
          order = 11400; # Before unix-early at 11500
        };
        # Check password - if correct, we're done (keyring already captured it)
        unix-early = {
          enable = true;
          control = lib.mkForce "sufficient";
          modulePath = "${pkgs.pam}/lib/security/pam_unix.so";
          settings = {
            likeauth = true;
            nullok = true;
          };
          order = 11500;
        };
        # If password wrong, try fingerprint
        fprintd = {
          enable = true;
          control = "sufficient";
          modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
          order = 12300;
        };
        # Disable the final unix check that uses try_first_pass
        # (it would fail auth even if biometrics succeed with a wrong password)
        unix = {
          enable = lib.mkForce false;
        };
      };
    in {
      sudo.rules.auth = biometricsFirstAuth;
      polkit-1.rules.auth = biometricsFirstAuth;

      # greetd: Use default NixOS PAM with enableGnomeKeyring (set in login.nix)
      # This avoids the "no password is available" issue by letting NixOS
      # configure the PAM stack correctly for keyring auto-unlock
      # Explicitly disable fprintd for greetd only
      greetd.rules.auth.fprintd.enable = lib.mkForce false;
      
      # login/hyprlock: Keep biometric fallback with fingerprint
      login.rules.auth = passwordFirstWithBiometrics;
      hyprlock.rules.auth = passwordFirstWithBiometrics;
    };
  };

  biometricAuth.fingerprint.enable = true;

  hm.home.stateVersion = "24.11";
}
