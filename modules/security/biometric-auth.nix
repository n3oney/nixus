{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.biometricAuth;
in {
  options.biometricAuth = {
    howdy = {
      enable = lib.mkEnableOption "Howdy facial authentication";
      package = lib.mkOption {
        default = pkgs.howdy;
      };

      biometricsFirst = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "sudo"
          "polkit-1"
        ];
        description = "Services where biometrics are tried before password";
      };

      passwordFirst = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "hyprlock"
          "login"
        ];
        description = "Services where password is checked before biometrics (for UIs with password fields)";
      };
    };

    fingerprint = {
      enable = lib.mkEnableOption "Fingerprint authentication";
    };
  };

  config = (
    let
      # PAM rule generators
      mkHowdyRule = order: {
        enable = true;
        control = "sufficient";
        modulePath = "${cfg.howdy.package}/lib/security/pam_howdy.so";
        inherit order;
      };

      mkFprintdRule = order: {
        enable = true;
        control = "sufficient";
        modulePath = "${pkgs.fprintd}/lib/security/pam_fprintd.so";
        inherit order;
      };

      # Order presets
      # Biometrics-first: face -> fingerprint -> password
      # Used for sudo, polkit where there's no password prompt UI
      biometricsFirstOrders = {
        howdy = 0;
        fprintd = 100;
      };

      # Password-first: password -> face -> fingerprint
      # Used for greeters/lockers that show a password field
      # unix-early is at 11600 (optional), gnome_keyring at 12200, unix final is at 12900
      passwordFirstOrders = {
        howdy = 12100;
        fprintd = 12300;
      };

      # Build PAM services config based on enabled features
      mkPamServices = services: orderPreset:
        lib.listToAttrs (
          map (svc: {
            name = svc;
            value = {
              # Disable upstream howdy PAM integration since we manage it manually with custom ordering
              howdy.enable = lib.mkForce false;
              
              rules.auth = lib.mkMerge [
                (lib.mkIf cfg.howdy.enable {
                  howdy-custom = mkHowdyRule orderPreset.howdy;
                })
                (lib.mkIf cfg.fingerprint.enable {
                  fprintd = mkFprintdRule orderPreset.fprintd;
                })
              ];
            };
          })
          services
        );
    in
      lib.mkMerge [
        # Howdy service configuration
        (lib.mkIf cfg.howdy.enable {
          os = {
            services.howdy = {
              enable = true;
              package = cfg.howdy.package;
            };
            services.linux-enable-ir-emitter = {
              enable = true;
              package = pkgs.linux-enable-ir-emitter;
            };

            security.pam.services = lib.mkMerge [
              (mkPamServices cfg.howdy.biometricsFirst biometricsFirstOrders)
              (mkPamServices cfg.howdy.passwordFirst passwordFirstOrders)
            ];
          };

          impermanence.systemDirs = ["/var/lib/howdy"];
        })

        # Fingerprint service configuration
        (lib.mkIf cfg.fingerprint.enable {
          os = {
            services.fprintd.enable = true;

            systemd.services.fprintd = {
              wantedBy = ["multi-user.target"];
              serviceConfig.Type = "simple";
            };

            # Override default fprintd PAM rules for password-first services
            security.pam.services = lib.mkIf cfg.howdy.enable (
              mkPamServices cfg.howdy.passwordFirst passwordFirstOrders
            );
          };
        })

        # Fingerprint-only (no howdy) - use default NixOS fprintd PAM behavior
        (lib.mkIf (cfg.fingerprint.enable && !cfg.howdy.enable) {
          os.security.pam.services =
            mkPamServices [
              "sudo"
              "polkit-1"
              "greetd"
              "hyprlock"
              "login"
            ]
            biometricsFirstOrders;
        })
      ]
  );
}
