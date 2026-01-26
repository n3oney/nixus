{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkOption types;
  mainMod = "SUPER";
  mkBind = bind: action: comment: {inherit bind action comment;};
  windowSwitchBind = bind: direction: comment: mkBind "${mainMod}, ${bind}" "exec, hyprctl activewindow -j | $(jaq -r \"if .fullscreen != 0 then \\\"hyprctl dispatch focusmonitor ${direction}\\\" else \\\"hyprctl dispatch movefocus ${direction}\\\" end\")" comment;

  binds =
    [
      (mkBind "${mainMod}, Return" "exec, ${
        if config.programs.foot.enable
        then "uwsm app -- foot"
        else "false"
      }" "Launch terminal")
      (mkBind "${mainMod}, W" "killactive," "Close focused window")
      (mkBind "${mainMod}, M" "exit," "Close Hyprland")
      (mkBind "${mainMod}, P" "exec, hyprpicker -a" "Open color picker")
      (mkBind "${mainMod}, S" "togglefloating," "Toggle floating")
      (mkBind "${mainMod}, space" "exec, uwsm app -- anyrun" "Open application launcher")
      (mkBind "${mainMod}, T" "togglesplit," "Toggle split direction")
      (mkBind "${mainMod}, Q" "togglespecialworkspace," "Toggle special workspace")
      (mkBind "${mainMod}, C" "movetoworkspace, special" "Move window to special workspace")

      (mkBind "${mainMod}, F" "fullscreen," "Toggle fullscreen")

      (mkBind "${mainMod}, e" "exec, wl-paste | swappy -f - -o - | wl-copy -t image/png && notify-send 'Copied!' --expire-time 1000" "Edit copied image")

      (mkBind "${mainMod}, r" "exec, ${lib.getExe pkgs.kooha}" "Start screen recording")

      # keyboard layouts
      (mkBind "${mainMod}, F1" "exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"basic\"") cfg.keyboards}" "Switch to QWERTY")
      (mkBind "${mainMod}, F2" "exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"colemak_dh_ansi\"") cfg.keyboards}" "Switch to Colemak DH")

      # volume (mute only)
      (mkBind ", XF86AudioMute" "exec, pactl set-sink-mute @DEFAULT_SINK@ toggle" null)

      # music
      (mkBind ", XF86AudioPlay" "exec, ${lib.getExe pkgs.playerctl} play-pause" null)
      (mkBind ", XF86AudioNext" "exec, ${lib.getExe pkgs.playerctl} next" null)
      (mkBind ", XF86AudioPrev" "exec, ${lib.getExe pkgs.playerctl} previous" null)

      (mkBind "${mainMod} , z" ''exec, sleep 1 && ${lib.getExe pkgs.wtype} " +:hesrightyouknow:" -P Return -p Return'' "He's right you know.")

      # move focus
      (windowSwitchBind "left" "l" "Move to window on the left")
      (windowSwitchBind "right" "r" "Move to window on the right")
      (windowSwitchBind "up" "u" "Move to window above")
      (windowSwitchBind "down" "d" "Move to window below")
    ]
    # Screenshots
    ++ (lib.optionals (cfg.screenshotKeybinds.active != null) [(mkBind cfg.screenshotKeybinds.active "exec, grimblast save active - | shadower -r ${builtins.toString (let c = hmConfig.wayland.windowManager.hyprland.settings; in c.decoration.rounding + 2 * c.general.border_size)} | wl-copy -t image/png && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of active window")])
    ++ (lib.optionals (cfg.screenshotKeybinds.area != null) [(mkBind cfg.screenshotKeybinds.area "exec, pauseshot | shadower | wl-copy -t image/png && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of an area")])
    ++ (lib.optionals (cfg.screenshotKeybinds.all != null) [(mkBind cfg.screenshotKeybinds.all "exec, grimblast copy && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of everything")])
    ++ (lib.optionals (cfg.screenshotKeybinds.monitor != null) [(mkBind cfg.screenshotKeybinds.monitor "exec, grimblast copy output && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of current monitor")])
    # mute for secondary
    ++ (lib.optionals (cfg.secondarySink != null) [(mkBind "ALT, XF86AudioMute" "exec, pactl set-sink-mute ${cfg.secondarySink} toggle" null)]);
in {
  options.display = {
    screenshotKeybinds = {
      active = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      area = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      all = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
      monitor = mkOption {
        type = types.nullOr types.str;
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      bind = builtins.map (b: b.bind + "," + b.action) binds;

      binde =
        [
          # Volume controls
          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"

          # Brightness
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} set +5%"
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} set 5%-"
        ]
        ++ (lib.optionals (cfg.secondarySink != null) ["ALT, XF86AudioRaiseVolume, exec, pactl set-sink-volume ${cfg.secondarySink} +5%" "ALT, XF86AudioLowerVolume, exec, pactl set-sink-volume ${cfg.secondarySink} -5%"]);

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = [
        "${mainMod}, mouse:272, movewindow"
        "${mainMod}, mouse:273, resizewindow"
      ];
    };
  };
}
