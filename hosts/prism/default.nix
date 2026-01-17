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

    # overlay because the module in nixpkgs incorrectly uses pkgs.buffybox instead of cfg.package
    nixpkgs.overlays = [
      (_: prev: {
        buffybox = prev.buffybox.overrideAttrs (old: {
          patches = (old.patches or []) ++ [./unl0kr-performance.patch];
        });
      })
    ];

    # On-screen keyboard for touchscreen LUKS unlock
    boot.initrd.unl0kr = {
      allowVendorDrivers = true;
      enable = true;
      settings = {
        general = {
          backend = "drm";
          animations = "false";
        };
        theme.default = "pmos-dark";
      };
    };
    boot.initrd.systemd.enable = true; # Required for unl0kr

    # Make unl0kr wait for DRM device (amdgpu) to be ready and force high performance
    boot.initrd.systemd.services.unl0kr-agent = {
      serviceConfig = {
        ExecStartPre = [
          # Wait for card0
          "/bin/sh -c 'timeout=100; while [ ! -e /dev/dri/card0 ] && [ $timeout -gt 0 ]; do sleep 0.1; timeout=$((timeout-1)); done; [ -e /dev/dri/card0 ] || exit 1'"
          # Wait for power control
          "/bin/sh -c 'timeout=100; while [ ! -w /sys/class/drm/card0/device/power_dpm_force_performance_level ] && [ $timeout -gt 0 ]; do sleep 0.1; timeout=$((timeout-1)); done'"
          # Force high performance
          "/bin/sh -c 'echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level || echo \"Failed to set GPU high\"'"
          # Log clock state for verification
          "/bin/sh -c 'echo \"GPU Clock State:\"; cat /sys/class/drm/card0/device/pp_dpm_sclk || true'"
        ];
      };
    };

    # Plymouth conflicts with unl0kr - must be disabled
    # See: https://github.com/NixOS/nixpkgs/issues/291935
    boot.plymouth.enable = lib.mkForce false;
    # boot.plymouth = {
    #   enable = true;
    #   theme = "rings";
    #   themePackages = [
    #     (pkgs.adi1090x-plymouth-themes.override {
    #       selected_themes = ["rings"];
    #     })
    #   ];
    # };

    # Silent boot (splash removed - conflicts with unl0kr)
    boot.consoleLogLevel = 3;
    boot.initrd.verbose = false;
    boot.kernelParams = [
      "quiet"
      # "splash"  # Removed - conflicts with unl0kr
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "initcall_blacklist=sysfb_init" # Prevent simple-framebuffer platform device creation
      "video=simplefb:off" # Additional safety: disable simplefb driver
      "amdgpu.ppfeaturemask=0xffffffff" # Enable all power features
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
