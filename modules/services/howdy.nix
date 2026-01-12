{
  lib,
  config,
  inputs,
  pkgs,
  ...
}: let
  cfg = config.services.howdy;
  howdyPkgs = inputs.nixpkgs-howdy.legacyPackages.${pkgs.system};
  
  # PAM rule for howdy - order 0 to run before other auth methods
  howdyRule = {
    enable = true;
    control = "sufficient";
    modulePath = "${howdyPkgs.howdy}/lib/security/pam_howdy.so";
    order = 0;
  };
in {
  options.services.howdy = {
    enable = lib.mkEnableOption "Howdy facial authentication (Windows Hello style)";
  };

  config = lib.mkIf cfg.enable {
    osModules = [
      "${inputs.nixpkgs-howdy}/nixos/modules/services/security/howdy"
      "${inputs.nixpkgs-howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
    ];

    os = {
      services.howdy = {
        enable = true;
        package = howdyPkgs.howdy;
      };
      services.linux-enable-ir-emitter = {
        enable = true;
        package = howdyPkgs.linux-enable-ir-emitter;
      };

      # Add howdy PAM authentication for common services
      security.pam.services = {
        sudo.rules.auth.howdy = howdyRule;
        polkit-1.rules.auth.howdy = howdyRule;
        login.rules.auth.howdy = howdyRule;
        hyprlock.rules.auth.howdy = howdyRule;
        swaylock.rules.auth.howdy = howdyRule;
      };
    };

    # Persist face models
    impermanence.systemDirs = ["/var/lib/howdy"];
  };
}
