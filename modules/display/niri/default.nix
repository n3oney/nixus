{
  pkgs,
  lib,
  inputs,
  config,
  hmConfig,
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

  # Import niri-flake internals to access settings.render, allowing us to keep
  # programs.niri.settings while appending extra KDL nodes unsupported by the module.
  call = pkgs.lib.flip import {
    inherit inputs;
    inherit (pkgs) lib;
    kdl = call "${inputs.niri-flake}/kdl.nix";
    binds = call "${inputs.niri-flake}/parse-binds.nix";
    docs = call "${inputs.niri-flake}/generate-docs.nix";
    settings = call "${inputs.niri-flake}/settings.nix";
  };
  niriSettings = call "${inputs.niri-flake}/settings.nix";
in {
  imports = [
    ./monitors.nix
    ./binds.nix
    ./wallpaper.nix
    ./startup.nix
    ./rules.nix
    ./screenshot.nix
  ];

  config = mkIf cfg.enable {
    # Inject niri-flake HM module so programs.niri.settings is available
    hmModules = [inputs.niri-flake.homeModules.config];

    os = {
      nixpkgs.overlays = [inputs.niri-flake.overlays.niri];
      programs.niri.enable = true;
      programs.niri.package = pkgs.niri-unstable;

      # niri provides its own portal config; disable the wlr portal
      xdg.portal.wlr.enable = lib.mkForce false;
    };

    hm.programs.niri.package = pkgs.niri-unstable;

    hm.programs.niri.settings = {
      xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
      prefer-no-csd = true;

      hotkey-overlay.skip-at-startup = true;

      # screenshot-path = "/tmp/niri-screenshot-%Y-%m-%d_%H-%M-%S.png"; # TODO: restore when shadower daemon is set up

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
        };
        focus-follows-mouse.enable = true;
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

    hm.programs.niri.config = with inputs.niri-flake.lib.kdl;
      (niriSettings.render hmConfig.programs.niri.settings)
      ++ [
        # Blur all windows
        (plain "window-rule" [
          (plain "background-effect" [
            (leaf "blur" true)
          ])
        ])
        # Blur notifications and bar layer surfaces
        (plain "layer-rule" [
          (leaf "match" {namespace = "^(notifications|bar)$";})
          (plain "background-effect" [
            (leaf "blur" true)
          ])
        ])
        # Block notifications from screencast
        (plain "layer-rule" [
          (leaf "match" {namespace = "^notifications$";})
          (leaf "block-out-from" "screencast")
        ])
      ];
  };
}
