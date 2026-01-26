{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkOption types mkIf optional optionals concatStringsSep;

  # Normalize workspace entry (int or submodule -> consistent attrs)
  normalizeWs = ws:
    if builtins.isInt ws
    then {
      id = ws;
      default = false;
      gapsIn = null;
      gapsOut = null;
      border = null;
    }
    else ws;

  # Generate monitor config line
  mkMonitorConfig = monitor: let
    scaleStr = toString monitor.scale;
  in "${monitor.name}, ${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}, ${monitor.position}, ${scaleStr}, transform, ${monitor.transform}";

  # Generate workspace rule string
  mkWorkspaceRule = monitor: ws: let
    w = normalizeWs ws;
    parts =
      ["${toString w.id}" "monitor:${monitor.name}"]
      ++ optional (w.default or false) "default:true"
      ++ optional (w.gapsIn != null) "gapsin:${toString w.gapsIn}"
      ++ optional (w.gapsOut != null) "gapsout:${toString w.gapsOut}"
      ++ optional (w.border != null && !w.border) "border:0";
  in
    concatStringsSep ", " parts;

  # Generate workspace keybinds (switch + move)
  mkWorkspaceBinds = monitor: ws: let
    w = normalizeWs ws;
    key =
      if monitor.workspaceKey != null
      then monitor.workspaceKey w.id
      else null;
  in
    optionals (monitor.workspaceMod != null && key != null) [
      "${monitor.workspaceMod}, ${key}, workspace, ${toString w.id}"
      "${monitor.workspaceMod} SHIFT, ${key}, movetoworkspace, ${toString w.id}"
    ];

  # Generate all monitor config lines
  monitorConfigs = map mkMonitorConfig cfg.monitors;

  # Generate all workspace rules
  workspaceRules =
    (lib.flatten (map (monitor: map (mkWorkspaceRule monitor) monitor.workspaces) cfg.monitors))
    ++ [
      # Static rules for special window types
      "w[t1], gapsin:0, gapsout:0, border:0"
      "w[tg1], gapsin:0, gapsout:0, border:0"
      "f[1], gapsin:0, gapsout:0, border:0"
    ];

  # Generate all workspace keybinds
  workspaceBinds = lib.flatten (map (monitor: lib.flatten (map (mkWorkspaceBinds monitor) monitor.workspaces)) cfg.monitors);
in {
  options.display = {
    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor name (e.g., DP-1, HDMI-A-1)";
          };
          width = mkOption {
            type = types.int;
            description = "Monitor width in pixels";
          };
          height = mkOption {
            type = types.int;
            description = "Monitor height in pixels";
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
            description = "Monitor refresh rate in Hz";
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "Monitor scale factor";
          };
          position = mkOption {
            type = types.str;
            default = "auto";
            description = "Monitor position (e.g., '0x0', 'auto-right', '317x1440')";
          };
          transform = mkOption {
            type = types.str;
            default = "0";
            description = "Monitor transform (rotation)";
          };
          isMain = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this is the main monitor";
          };

          workspaces = mkOption {
            type = types.listOf (types.either types.int (types.submodule {
              options = {
                id = mkOption {
                  type = types.int;
                  description = "Workspace ID";
                };
                default = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether this is the default workspace for this monitor";
                };
                gapsIn = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  description = "Inner gaps override for this workspace";
                };
                gapsOut = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  description = "Outer gaps override for this workspace";
                };
                border = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Border override for this workspace";
                };
              };
            }));
            default = [];
            description = "List of workspaces assigned to this monitor";
          };

          workspaceMod = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Modifier keys for workspace keybinds (e.g., 'SUPER', 'SUPER ALT'). If null, no keybinds are generated.";
          };

          workspaceKey = mkOption {
            type = types.nullOr (types.functionTo types.str);
            default = null;
            description = "Function: workspace id -> key string (e.g., '1', '0'). Used with workspaceMod to generate keybinds.";
          };
        };
      });
      default = [];
      description = "List of monitors";
    };
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      monitor = monitorConfigs;
      workspace = workspaceRules;
      bind = workspaceBinds;
    };
  };
}
