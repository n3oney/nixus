{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkEnableOption mkOption types mkIf;
  # Note: display.enable, monitors, keyboards, mouseSensitivity, deviceOverrides,
  # screenshotKeybinds are defined in ../options.nix
in {
  imports = [
    ./binds.nix
    ./rules.nix
    ./appearance.nix
    ./wallpaper.nix
    ./monitors.nix
    ./packages.nix
    ./startup.nix
    ./idle.nix
    ./lock.nix
    ./gyro.nix
    ./gestures.nix
  ];

  options.display = {
    # Hyprland-specific options (compositor-agnostic options are in ../options.nix)
    enableTearing = mkEnableOption "Tearing";

    package = mkOption {
      type = types.package;
      default = pkgs.hyprland;
    };
  };

  config = mkIf cfg.enable {
    os = {
      assertions = [
        {
          assertion = config.programs.foot.enable;
          message = "You haven't enabled any terminal emulator. Enable programs.foot.";
        }
      ];

      environment.sessionVariables.NIXOS_OZONE_WL = "1";
      nixpkgs.overlays = [inputs.hyprland.overlays.default];

      programs.uwsm = {
        enable = true;
      };

      programs.hyprland = {
        enable = true;
        inherit (cfg) package;
        withUWSM = true;
      };

      xdg.portal = {
        enable = true;
        wlr.enable = lib.mkForce false;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        xdgOpenUsePortal = true;
      };

      # locker on sleep
      systemd.services.locker = {
        before = ["sleep.target"];
        wantedBy = ["sleep.target"];
        script = "${pkgs.systemd}/bin/loginctl lock-sessions";
      };

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
      };
    };

    hm = {
      wayland.windowManager.hyprland = {
        enable = true;

        inherit (cfg) package;

        # Disable systemd integration as it conflicts with UWSM
        systemd.enable = false;

        settings = {
          cursor = {
            persistent_warps = true;
            inactive_timeout = 30.0;
          };

          input = {
            kb_layout = "pl";
            kb_options = "caps:backspace";

            # Mouse speed
            accel_profile = "flat";
            sensitivity = toString cfg.mouseSensitivity;
            follow_mouse = true;

            touchpad = {
              disable_while_typing = true;
              drag_lock = true;
              clickfinger_behavior = true;
            };
          };

          device = cfg.deviceOverrides;

          gesture = [
            "3, horizontal, workspace"
            "3, swipe, mod:SUPER, resize"
          ];

          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };

          misc = {
            disable_hyprland_logo = true;
            vfr = true;
            vrr = 1; # 0=off, 1=on (always), 2=fullscreen only, 3=fullscreen video/game
            animate_manual_resizes = true;
            animate_mouse_windowdragging = true;
          };

          env = lib.mkIf cfg.enableTearing ["AQ_DRM_NO_ATOMIC,1"];

          general = {
            allow_tearing = cfg.enableTearing;
            gaps_in = 8;
            gaps_out = 14;
            border_size = 2;
            "col.active_border" = "rgb(${config.colors.colorScheme.palette.accent})";
            "col.inactive_border" = "rgb(2B2937)";

            layout = "dwindle";
          };

          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
        };
      };
    };
  };
}
