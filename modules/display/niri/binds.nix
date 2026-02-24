{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # Normalize Hyprland-style modifier strings to niri style
  # "SUPER" -> "Super", "SUPER ALT" -> "Super+Alt"
  normalizemod = mod:
    lib.concatStringsSep "+" (
      map (m: let
        lower = lib.toLower m;
      in
        if lower == "super" then "Super"
        else if lower == "shift" then "Shift"
        else if lower == "alt" then "Alt"
        else if lower == "ctrl" then "Ctrl"
        else m)
      (lib.splitString " " mod)
    );

  # Convert Hyprland-style bind "MOD, key" to niri style "Mod+Key"
  # e.g. "SHIFT, Print" -> "Shift+Print", ", Print" -> "Print"
  hlBindToNiri = bind: let
    parts = lib.splitString ", " bind;
    mod = builtins.head parts;
    key = builtins.elemAt parts 1;
  in
    if mod == ""
    then key
    else "${normalizemod mod}+${key}";

  # Build optional screenshot bind attrset
  mkScreenshotBind = keybind: action:
    lib.optionalAttrs (keybind != null) {
      "${hlBindToNiri keybind}".action = action;
    };
in {
  config = mkIf cfg.enable {
    hm.programs.niri.settings.binds =
      # Window management
      {
        "Mod+W".action.close-window = {};
        "Mod+M".action.quit = {};
        "Mod+F".action.maximize-column = {};
        "Mod+Shift+F".action.fullscreen-window = {};
        "Mod+S".action.toggle-column-tabbed-display = {};

        # Focus
        "Mod+Left".action.focus-column-left = {};
        "Mod+Right".action.focus-column-right = {};
        "Mod+Up".action.focus-window-up = {};
        "Mod+Down".action.focus-window-down = {};

        # Move
        "Mod+Shift+Left".action.move-column-left = {};
        "Mod+Shift+Right".action.move-column-right = {};
        "Mod+Shift+Up".action.move-window-up = {};
        "Mod+Shift+Down".action.move-window-down = {};

        # Workspaces
        "Mod+U".action.focus-workspace-down = {};
        "Mod+I".action.focus-workspace-up = {};
        "Mod+Shift+U".action.move-column-to-workspace-down = {};
        "Mod+Shift+I".action.move-column-to-workspace-up = {};

        # Resize
        "Mod+R".action.switch-preset-column-width = {};
        "Mod+C".action.center-column = {};
        "Mod+Minus".action.set-column-width = "-10%";
        "Mod+Equal".action.set-column-width = "+10%";

        # Terminal
        "Mod+Return".action.spawn =
          if config.programs.foot.enable
          then "foot"
          else "xterm";

        # App launcher
        "Mod+Space".action.spawn = ["vicinae" "toggle"];

        # Color picker
        "Mod+P".action.spawn = ["hyprpicker" "-a"];


        # Volume
        "XF86AudioRaiseVolume".action.spawn = ["pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"];
        "XF86AudioLowerVolume".action.spawn = ["pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"];
        "XF86AudioMute".action.spawn = ["pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"];

        # Brightness
        "XF86MonBrightnessUp".action.spawn = ["${lib.getExe pkgs.brightnessctl}" "set" "+5%"];
        "XF86MonBrightnessDown".action.spawn = ["${lib.getExe pkgs.brightnessctl}" "set" "5%-"];

        # Media
        "XF86AudioPlay".action.spawn = ["${lib.getExe pkgs.playerctl}" "play-pause"];
        "XF86AudioNext".action.spawn = ["${lib.getExe pkgs.playerctl}" "next"];
        "XF86AudioPrev".action.spawn = ["${lib.getExe pkgs.playerctl}" "previous"];
      }
      # Screenshots
      // mkScreenshotBind cfg.screenshotKeybinds.area {screenshot = {};}
      // mkScreenshotBind cfg.screenshotKeybinds.active {screenshot-window = {};}
      // mkScreenshotBind cfg.screenshotKeybinds.monitor {screenshot-screen = {};}
      # Workspace keybinds from monitor config
      // lib.listToAttrs (
        lib.flatten (
          map (
            monitor:
              lib.flatten (
                map (
                  ws: let
                    id =
                      if builtins.isInt ws
                      then ws
                      else ws.id;
                    key =
                      if monitor.workspaceKey != null
                      then monitor.workspaceKey id
                      else null;
                    mod = normalizemod monitor.workspaceMod;
                  in
                    lib.optionals (monitor.workspaceMod != null && key != null) [
                      {
                        name = "${mod}+${key}";
                        value.action.focus-workspace = toString id;
                      }
                      {
                        name = "${mod}+Shift+${key}";
                        value.action.move-column-to-workspace = toString id;
                      }
                    ]
                )
                monitor.workspaces
              )
          )
          cfg.monitors
        )
      );
  };
}
