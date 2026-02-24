{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf optional optionals concatStringsSep;

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
  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      monitor = monitorConfigs;
      workspace = workspaceRules;
      bind = workspaceBinds;
    };
  };
}
