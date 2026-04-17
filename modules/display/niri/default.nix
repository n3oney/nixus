{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # Use first deviceOverride's sensitivity if set, else fall back to mouseSensitivity
  # (niri has no per-device overrides, so we pick the most relevant value)
  mouseAccelSpeed =
    if cfg.deviceOverrides != []
    then (builtins.head cfg.deviceOverrides).sensitivity or cfg.mouseSensitivity
    else cfg.mouseSensitivity;
in {
  imports = [
    ./monitors.nix
    ./binds.nix
    ./startup.nix
    ./rules.nix
    ./screenshot.nix
  ];

  config = mkIf cfg.enable {
    # Inject niri-flake HM module so programs.niri.settings is available
    hmModules = ["${inputs.niri-flake}/modules/experimental/home-manager/settings.nix"];

    os = {
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri;

      xdg.portal = {
        enable = true;
        # niri provides its own portal config; disable the wlr portal
        wlr.enable = lib.mkForce false;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        xdgOpenUsePortal = true;
      };
    };

    hm.programs.niri.settings-validation-package = null;

    hm.programs.niri.settings = {
      includes = lib.mkAfter [./extras.kdl];

      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      prefer-no-csd = true;

      hotkey-overlay.skip-at-startup = true;

      # screenshot-path = "/tmp/niri-screenshot-%Y-%m-%d_%H-%M-%S.png"; # TODO: restore when shadower daemon is set up
      #

      input = {
        keyboard = {
          xkb = {
            layout = "pl";
            options = "caps:backspace";
          };
        };
        mouse = {
          accel-profile = "flat";
          accel-speed = mouseAccelSpeed;
        };
        touchpad = {
          tap = true;
          natural-scroll = true;
          accel-profile = "flat";
          drag-lock = true;
          click-method = "clickfinger";
          dwt = true;
          scroll-factor = 0.3;
        };
        warp-mouse-to-focus.enable = true;
      };

      layout = {
        gaps = 14;
        focus-ring = {
          enable = true;
          width = 2;
          active.color = "#${config.colors.colorScheme.palette.accent}";
          inactive.color = "#2B2937";
        };
        border.enable = false;
      };

      window-rules = [
        {
          geometry-corner-radius = let
            r = cfg.niri.cornerRadius;
          in {
            top-left = r;
            top-right = r;
            bottom-left = r;
            bottom-right = r;
          };
          clip-to-geometry = true;
        }
        {
          matches = [{app-id = "^foot$";}];
          default-column-width.proportion = 0.5;
        }
        {
          matches = [{app-id = "^dev\\.zed\\.Zed$";}];
          draw-border-with-background = false;
        }
      ];
    };
  };
}
