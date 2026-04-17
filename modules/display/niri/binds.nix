{
  pkgs,
  lib,
  config,
  hmConfig,
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
        if lower == "super"
        then "Super"
        else if lower == "shift"
        then "Shift"
        else if lower == "alt"
        then "Alt"
        else if lower == "ctrl"
        then "Ctrl"
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
          then "${hmConfig.programs.foot.package}/bin/foot"
          # if foot not enabled, default to installing xterm anyways
          else "${pkgs.xterm}/bin/xterm";

        # App launcher
        "Mod+Space".action.spawn = ["${hmConfig.programs.vicinae.package}/bin/vicinae" "toggle"];

        # Lock
        "Mod+L".action.spawn = ["loginctl" "lock-session"];

        # Color picker
        "Mod+P".action.spawn = ["${pkgs.hyprpicker}/bin/hyprpicker" "-a"];

        # Volume
        "XF86AudioRaiseVolume".action.spawn = ["${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"];
        "XF86AudioLowerVolume".action.spawn = ["${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"];
        "XF86AudioMute".action.spawn = ["${pkgs.pulseaudio}/bin/pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"];

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
      # noctalia panels / IPC (only where noctalia drives the shell)
      // lib.optionalAttrs cfg.noctalia.enable (let
        noctalia = "${hmConfig.programs.noctalia.package}/bin/noctalia";
        msg = cmd: {action.spawn = [noctalia "msg"] ++ cmd;};
      in {
        "Mod+V" = msg ["panel-toggle" "clipboard"];
        "Mod+N" = msg ["panel-toggle" "control-center" "notifications"];

        # Route audio + brightness through noctalia so its state/OSD stay
        # authoritative. (brightness is a no-op on miko — kept for the laptop.)
        "XF86AudioRaiseVolume" = msg ["volume-up"];
        "XF86AudioLowerVolume" = msg ["volume-down"];
        "XF86AudioMute" = msg ["volume-mute"];
        "XF86MonBrightnessUp" = msg ["brightness-up"];
        "XF86MonBrightnessDown" = msg ["brightness-down"];
      })
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
