{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkOption types mkIf optionals;

  mainMonitor = cfg.monitors.main.name;
  secondaryMonitor = cfg.monitors.secondary.name;
  hasSecondary = secondaryMonitor != null;
in {
  options.display = {
    monitors = {
      main = {
        name = mkOption {type = types.str;};
        width = mkOption {type = types.int;};
        height = mkOption {type = types.int;};
        scale = mkOption {
          type = types.float;
          default = 1.0;
        };
        refreshRate = mkOption {
          type = types.int;
          default = 60;
        };
        transform = mkOption {
          type = types.str;
          default = "0";
        };
      };
      secondary = {
        name = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        width = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
        height = mkOption {
          type = types.nullOr types.int;
          default = null;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      # Legacy monitor syntax: name, resolution@rate, position, scale, transform:N
      monitor = let
        mainScale = toString cfg.monitors.main.scale;
        mainConfig = "${mainMonitor}, ${toString cfg.monitors.main.width}x${toString cfg.monitors.main.height}@${toString cfg.monitors.main.refreshRate}, 0x0, ${mainScale}, transform, ${cfg.monitors.main.transform}";
        secondaryConfig = "${secondaryMonitor}, ${toString cfg.monitors.secondary.width}x${toString cfg.monitors.secondary.height}@60, auto-right, auto";
      in
        [mainConfig] ++ (optionals hasSecondary [secondaryConfig]);

      workspace = let
        # Map 1-10 to Main
        mainWorkspaces = map (n: "${toString n},monitor:${mainMonitor}") (lib.range 1 10);

        # Map 11-20 to Secondary (if exists)
        secondaryWorkspaces = optionals hasSecondary (
          map (n: "${toString n},monitor:${secondaryMonitor}") (lib.range 11 20)
        );

        # Special Workspace Logic (WS 19 or 9)
        # Used for "gaming/media" focus - typically implies no gaps
        specialWorkspace =
          if hasSecondary
          then "19,monitor:${secondaryMonitor}, default:true, gapsin:0, gapsout:0"
          else "9,monitor:${mainMonitor}, gapsin:0, gapsout:0";

        # Specific static rules
        staticRules = [
          "1,monitor:${mainMonitor}, gapsin:0, gapsout:0"
          "2,monitor:${mainMonitor}, default:true"
          "w[t1], gapsin:0, gapsout:0, border:0"
          "w[tg1], gapsin:0, gapsout:0, border:0"
          "f[1], gapsin:0, gapsout:0, border:0"
        ];
      in
        mainWorkspaces ++ secondaryWorkspaces ++ [specialWorkspace] ++ staticRules;
    };
  };
}
