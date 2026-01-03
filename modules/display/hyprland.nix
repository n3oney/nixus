{
  pkgs,
  lib,
  inputs,
  config,
  hmConfig,
  osConfig,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkEnableOption mkOption types mkIf;

  # Use raw display resolution for wallpaper dimensions
  displayWidth = cfg.monitors.main.width;
  displayHeight = cfg.monitors.main.height;

  animatedWallpaper =
    pkgs.runCommand "animated-wallpaper" {
      nativeBuildInputs = [pkgs.ffmpeg];
      src = ../../wallpapers/animated.mp4;
    } ''
      mkdir -p $out
      # Scale to cover display maintaining aspect ratio, then crop to exact dimensions
      # force_original_aspect_ratio=increase ensures it covers the entire area
      ffmpeg -i $src -vf "scale=${toString displayWidth}:${toString displayHeight}:force_original_aspect_ratio=increase:flags=lanczos,crop=${toString displayWidth}:${toString displayHeight},palettegen=stats_mode=full" palette.png
      # Create GIF with exact dimensions
      ffmpeg -i $src -i palette.png -lavfi "scale=${toString displayWidth}:${toString displayHeight}:force_original_aspect_ratio=increase:flags=lanczos,crop=${toString displayWidth}:${toString displayHeight},paletteuse=dither=sierra2_4a" $out/animated.gif
      # Extract first frame at exact dimensions
      ffmpeg -i $src -vf "scale=${toString displayWidth}:${toString displayHeight}:force_original_aspect_ratio=increase:flags=lanczos,crop=${toString displayWidth}:${toString displayHeight}" -vframes 1 -q:v 2 $out/paused.png
      rm palette.png
    '';

  awwwPkg = inputs.awww.packages.${pkgs.system}.default;

  strOption = mkOption {
    type = types.str;
  };

  nullStrOption = mkOption {
    type = types.nullOr types.str;
    default = null;
  };
  intOption = mkOption {
    type = types.int;
  };
  floatOption = mkOption {
    type = types.float;
  };

  nullIntOption = mkOption {
    type = types.nullOr types.int;
    default = null;
  };

  mainMod = "SUPER";
  mkBind = bind: action: comment: {inherit bind action comment;};
  windowSwitchBind = bind: direction: comment: mkBind "${mainMod}, ${bind}" "exec, hyprctl activewindow -j | $(jaq -r \"if .fullscreen != 0 then \\\"hyprctl dispatch focusmonitor ${direction}\\\" else \\\"hyprctl dispatch movefocus ${direction}\\\" end\")" comment;
in {
  options.display = {
    enable = mkEnableOption "Display";

    enableTearing = mkEnableOption "Tearing";

    wallpaper.pauseOnBattery = mkEnableOption "Pause animated wallpaper on battery";

    package = mkOption {
      type = types.package;
      # default = inputs.hyprland.packages.${pkgs.system}.hyprland.override {
      # mesa = osConfig.hardware.opengl.package;
      # wlroots = inputs.hyprland.packages.${pkgs.system}.wlroots-hyprland.overrideAttrs (old: {
      # buildInputs = (old.buildInputs or []) ++ [osConfig.hardware.opengl.package];
      # });
      # };

      default = pkgs.hyprland;

      # default = pkgs.hyprland.overrideAttrs (old: {
      # src = pkgs.fetchFromGitHub {
      # owner = "hyprwm";
      # repo = "hyprland";
      # rev = "05c84304ccb1169b550504830139e07e28500a3b";
      # hash = "sha256-8PyLk/gfMo4asjbqsoXw1I3zfnkCPSSX0r6UCJP3ctw=";
      # };
      # });
    };

    monitors = {
      main = {
        name = strOption;
        width = intOption;
        height = intOption;
        scale = floatOption // {default = 1.0;};
        refreshRate = intOption // {default = 60;};
        transform = mkOption {
          type = types.str;
          default = "0";
        };
      };
      secondary = {
        name = nullStrOption;
        width = nullIntOption;
        height = nullIntOption;
      };
    };

    binds = mkOption {
      default =
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
        ] # switch workspaces 1-10
        ++ (builtins.map (n: mkBind "${mainMod}, ${toString (lib.mod n 10)}" "workspace, ${toString n}" null) (lib.range 1 10))
        ++ (builtins.map (n: mkBind "${mainMod} SHIFT, ${toString (lib.mod n 10)}" "movetoworkspace, ${toString n}" null) (lib.range 1 10))
        # switch workspaces 11 - 20
        ++ (lib.optionals (cfg.monitors.secondary.name != null) (builtins.map (n: mkBind "${mainMod} ALT, ${toString (lib.mod (n - 10) 10)}" "workspace, ${toString n}" null) (lib.range 11 20)) ++ (builtins.map (n: mkBind "${mainMod} ALT SHIFT, ${toString (lib.mod (n - 10) 10)}" "movetoworkspace, ${toString n}" null) (lib.range 11 20)))
        # Screenshots
        ++ (lib.optionals (cfg.screenshotKeybinds.active != null) [(mkBind cfg.screenshotKeybinds.active "exec, grimblast save active - | shadower -r ${builtins.toString (let c = hmConfig.wayland.windowManager.hyprland.settings; in c.decoration.rounding + 2 * c.general.border_size)} | wl-copy -t image/png && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of active window")])
        ++ (lib.optionals (cfg.screenshotKeybinds.area != null) [(mkBind cfg.screenshotKeybinds.area "exec, pauseshot | shadower | wl-copy -t image/png && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of an area")])
        # ++ (lib.optionals (cfg.screenshotKeybinds.area != null) [(mkBind cfg.screenshotKeybinds.area "exec, flameshot gui -r | shadower | wl-copy -t image/png && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of an area")])
        ++ (lib.optionals (cfg.screenshotKeybinds.all != null) [(mkBind cfg.screenshotKeybinds.all "exec, grimblast copy && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of everything")])
        ++ (lib.optionals (cfg.screenshotKeybinds.monitor != null) [(mkBind cfg.screenshotKeybinds.monitor "exec, grimblast copy output && ${pkgs.dunst}/bin/dunstify 'Screenshot taken' --expire-time 1000" "Take screenshot of current monitor")])
        # mute for secondary
        ++ (lib.optionals (cfg.secondarySink != null) [(mkBind "ALT, XF86AudioMute" "exec, pactl set-sink-mute ${cfg.secondarySink} toggle" null)]);
    };

    secondarySink = nullStrOption;

    keyboards = mkOption {
      type = types.listOf types.str;
      default = [];
    };

    mouseSensitivity = mkOption {
      type = types.float;
      default = 0;
    };

    screenshotKeybinds = {
      active = nullStrOption;
      area = nullStrOption;
      all = nullStrOption;
      monitor = nullStrOption;
    };
  };

  config = lib.mkMerge [
    (mkIf cfg.enable {
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
          IdleActionSec = "7min";
          IdleAction = "suspend";
          HandleLidSwitch = "suspend";
        };

        # udev rules for awww AC power control
        services.udev.extraRules = lib.mkIf cfg.wallpaper.pauseOnBattery (let
          awwwCtl = pkgs.writeShellScript "awww-power" ''
            DAEMON_PID=$(${pkgs.procps}/bin/pgrep -x awww-daemon)
            [ -z "$DAEMON_PID" ] && exit 0

            USER=$(${pkgs.procps}/bin/ps -o user= -p "$DAEMON_PID")
            USER_ID=$(${pkgs.coreutils}/bin/id -u "$USER")
            WAYLAND_DISPLAY=$(${pkgs.gnugrep}/bin/grep -z WAYLAND_DISPLAY /proc/$DAEMON_PID/environ | ${pkgs.coreutils}/bin/cut -d= -f2)

            case "$1" in
              on)
                ${pkgs.su}/bin/su "$USER" -c "XDG_RUNTIME_DIR=/run/user/$USER_ID WAYLAND_DISPLAY=$WAYLAND_DISPLAY ${awwwPkg}/bin/awww img ${animatedWallpaper}/animated.gif --transition-type fade --no-resize"
                ;;
              off)
                ${pkgs.su}/bin/su "$USER" -c "XDG_RUNTIME_DIR=/run/user/$USER_ID WAYLAND_DISPLAY=$WAYLAND_DISPLAY ${awwwPkg}/bin/awww img ${animatedWallpaper}/paused.png --transition-type fade --no-resize"
                ;;
            esac
          '';
        in ''
          SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${awwwCtl} on"
          SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${awwwCtl} off"
        '');
      };

      hm = let
        cursor = {
          package = pkgs.catppuccin-cursors.macchiatoTeal;
          name = "catppuccin-macchiato-teal-cursors";
          size = 24;
        };
      in {
        home.packages = with pkgs;
        with inputs.hyprcontrib.packages.${pkgs.system};
        with inputs.shadower.packages.${pkgs.system}; [
          inputs.hyprland-qtutils.packages.${pkgs.system}.hyprland-qtutils
          pulseaudio

          (pkgs.flameshot.override
            {enableWlrSupport = true;})

          # caprine-bin

          wl-clipboard

          (wlsunset.overrideAttrs (old: {
            src = fetchFromSourcehut {
              owner = "~kennylevinsen";
              repo = old.pname;
              rev = "81cfb0b4f8e44db9e5ecb36222a24d53a953e6aa";
              sha256 = "sha256-Lxuhsk4/5EHuKPkBbaRtCCQ/LFvIxyc+VQYEoaVT484=";
            };
          }))

          hyprpicker
          grimblast

          swayidle

          jaq
          shadower

          awwwPkg

          (writeShellScriptBin
            "pauseshot"
            ''
              pkill -9 hyprpicker # kill all hyprpicker instances before launching this - sometimes it lags out
              ${hyprpicker}/bin/hyprpicker -r -z &
              picker_proc=$!

              ${grimblast}/bin/grimblast save area -

              kill $picker_proc
            '')
        ];

        xdg.configFile."flameshot/flameshot.ini".text = lib.generators.toINI {} {
          General = {
            disabledGrimWarning = true;
          };
        };

        home.pointerCursor = {
          gtk.enable = true;
          inherit (cursor) name;
          inherit (cursor) package;
          inherit (cursor) size;
          x11 = {
            defaultCursor = cursor.name;
            enable = true;
          };
        };

        services.arrpc.enable = true;

        wayland.windowManager.hyprland = {
          enable = true;

          inherit (cfg) package;

          # Disable systemd integration as it conflicts with UWSM
          systemd.enable = false;

          settings = let
            lockSequence = "physlock -ldms && ${lib.getExe pkgs.swaylock} && physlock -Ld";
          in
            lib.mkMerge [
              {
                exec-once =
                  [
                    "dbus-update-activation-environment --systemd --all"
                    "hyprctl setcursor ${cursor.name} ${toString cursor.size}"
                    "${pkgs.playerctl}/bin/playerctld & mako"

                    (
                      if cfg.wallpaper.pauseOnBattery
                      then ''awww-daemon && sleep 1 && awww img ${animatedWallpaper}/$(cat /sys/class/power_supply/*/online 2>/dev/null | grep -q 1 && echo 'animated.gif' || echo 'paused.png') --transition-type fade --no-resize''
                      else ''awww-daemon && sleep 1 && awww img ${animatedWallpaper}/animated.gif --transition-type fade --no-resize''
                    )

                    "zen &"
                    "${lib.getExe config.programs.discord.finalPackage} &"
                    # "${lib.getExe pkgs.caprine-bin} &"

                    "wlsunset -l 52.2 -L 21 &"

                    ''${lib.getExe pkgs.xss-lock} --ignore-sleep -- ${lib.getExe pkgs.bash} -c ${builtins.toJSON lockSequence}''

                    ''swayidle timeout 300 '${lockSequence}' timeout 360 'hyprctl dispatch dpms off' timeout 420 'systemctl suspend' resume 'hyprctl dispatch dpms on' timeout 420 'test $(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r ".sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor") -lt 80 && systemctl suspend' ''

                    "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
                  ]
                  ++ (lib.optionals config.programs.ags.enable ["ags"]);

                monitorv2 =
                  [
                    {
                      output = cfg.monitors.main.name;
                      mode = "${toString cfg.monitors.main.width}x${toString cfg.monitors.main.height}@${toString cfg.monitors.main.refreshRate}";
                      position = "0x0";
                      scale = cfg.monitors.main.scale;
                      transform = cfg.monitors.main.transform;
                    }
                  ]
                  ++ (lib.optionals (cfg.monitors.secondary.name != null) [
                    {
                      output = cfg.monitors.secondary.name;
                      mode = "${toString cfg.monitors.secondary.width}x${
                        toString cfg.monitors.secondary.height
                      }@60";
                      position = "auto-right";
                      scale = "auto";
                      transform = "0";
                    }
                  ]);
                workspace =
                  (builtins.map (n: "${toString n},monitor:${cfg.monitors.main.name}") (lib.range 1 10))
                  ++ (lib.optionals (cfg.monitors.secondary.name != null) (builtins.map (n: "${toString n},monitor:${cfg.monitors.secondary.name}") (lib.range 11 20)))
                  ++ [
                    "${
                      toString (
                        if cfg.monitors.secondary.name != null
                        then 19
                        else 9
                      )
                    },monitor:${
                      if cfg.monitors.secondary.name != null
                      then cfg.monitors.secondary.name
                      else cfg.monitors.main.name
                    }, ${
                      if cfg.monitors.secondary.name != null
                      then "default:true, "
                      else ""
                    }gapsin:0, gapsout:0"
                  ]
                  ++ [
                    "1,monitor:${cfg.monitors.main.name}, gapsin:0, gapsout:0"
                    "2,monitor:${cfg.monitors.main.name}, default:true"
                    "w[t1], gapsin:0, gapsout:0, border:0"
                    "w[tg1], gapsin:0, gapsout:0, border:0"
                    "f[1], gapsin:0, gapsout:0, border:0"
                  ];

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

                device = [
                  {
                    name = "glorious-model-o-wireless";
                    sensitivity = -0.76;
                  }
                  {
                    name = "ydotoold-virtual-device-1";
                    sensitivity = 0;
                  }
                ];

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
                  vrr = 1;
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

                decoration = {
                  rounding = 20;

                  rounding_power = 4.0;

                  shadow = {
                    enabled = true;
                    color = "rgba(0000001A)";
                    ignore_window = true;
                    range = 20;
                    render_power = 2;
                    offset = "0 2";
                  };

                  dim_special = 0.6;

                  blur = {
                    enabled = true;
                    size = 5;
                    passes = 3;
                    contrast = 1;
                    brightness = 1;
                    noise = 0.01;
                  };
                };

                animations = {
                  enabled = true;

                  bezier = [
                    "linear, 0, 0, 1, 1"
                    "md3_standard, 0.2, 0, 0, 1"
                    "md3_decel, 0.05, 0.7, 0.1, 1"
                    "md3_accel, 0.3, 0, 0.8, 0.15"
                    "overshot, 0.05, 0.9, 0.1, 1.1"
                    "crazyshot, 0.1, 1.5, 0.76, 0.92"
                    "hyprnostretch, 0.05, 0.9, 0.1, 1.0"
                    "fluent_decel, 0.1, 1, 0, 1"
                    "easeInOutCirc, 0.85, 0, 0.15, 1"
                    "easeOutCirc, 0, 0.55, 0.45, 1"
                    "easeOutExpo, 0.16, 1, 0.3, 1"
                  ];

                  # Animation configs
                  animation = [
                    "windows, 1, 3, md3_decel, popin 60%"
                    "border, 1, 10, default"
                    "fade, 1, 2.5, md3_decel"
                    # animation = workspaces, 1, 3.5, md3_decel, slide
                    "workspaces, 1, 7, fluent_decel, slide"
                    # animation = workspaces, 1, 7, fluent_decel, slidefade 15%
                    # animation = specialWorkspace, 1, 3, md3_decel, slidefadevert 15%
                    "specialWorkspace, 1, 3, md3_decel, slidevert"
                  ];

                  # https://wiki.hyprland.org/Configuring/Animations/
                  # animation = [
                  # "windows, 1, 3, default"
                  # "windowsOut, 1, 3, default, popin 80%"
                  # "border, 1, 3, default"
                  # "fade, 1, 4, default"
                  # "workspaces, 1, 4, default, slide"
                  # ];
                };

                dwindle = {
                  pseudotile = true;
                  preserve_split = true;
                };

                windowrule = [
                  # Gaming - tearing and fullscreen suppression
                  "immediate on, match:class ^(cs2)$"
                  "suppress_event fullscreen, match:class ^(cs2)$"
                  "suppress_event maximize, match:class ^(cs2)$"
                  "immediate on, match:class ^(Minecraft.*)$"

                  # Misc window rules
                  "no_blur on, match:class ^(Xdg-desktop-portal-gtk)$"
                  "pin on, match:class ^(ssh-askpass)$"
                  "float on, match:class ^(ssh-askpass)$"
                  "idle_inhibit focus, match:title ^(YouTube on TV.*)$"
                  "idle_inhibit fullscreen, match:class ^(.*)$"
                  "float on, match:class ^([Ww]aydroid.*)$"

                  # Browser workspace
                  "workspace 2, match:class ^(zen)$"
                  "suppress_event maximize, match:class ^(zen)$"

                  # Workspace 1 styling (tiled windows)
                  "rounding 0, match:workspace 1, match:float false"
                  "border_size 1, match:workspace 1, match:float false"

                  # Flameshot
                  "move 0 0, match:class ^(flameshot)$, match:title ^(flameshot)$"
                  "pin on, match:class ^(flameshot)$, match:title ^(flameshot)$"
                  "fullscreen_state 2 2, match:class ^(flameshot)$, match:title ^(flameshot)$"
                  "float on, match:class ^(flameshot)$, match:title ^(flameshot)$"

                  # Chat workspace styling (tiled windows)
                  "rounding 0, match:workspace ${
                    toString (
                      if cfg.monitors.secondary.name != null
                      then 19
                      else 9
                    )
                  }, match:float false"
                  "border_size 1, match:workspace ${
                    toString (
                      if cfg.monitors.secondary.name != null
                      then 19
                      else 9
                    )
                  }, match:float false"

                  # Caprine workspace
                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "18"
                    else "8"
                  }, match:class ^(Caprine)$"

                  # Vesktop workspace
                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "19"
                    else "9"
                  }, match:class ^(vesktop)$"
                  "opacity 0.999, match:class ^(vesktop)$"

                  # YouTube Music workspace
                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "20"
                    else "10"
                  }, match:class ^(YouTube Music)$"

                  # Pauseshot
                  "no_anim on, match:title ^(PAUSESHOT)$"
                  "fullscreen on, match:title ^(PAUSESHOT)$"

                  # Remove max size limits from all windows
                  "no_max_size on, match:class ^(.*)$"
                ];

                bind = builtins.map (b: b.bind + "," + b.action) cfg.binds;

                binde =
                  [
                    # Volume controls
                    ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
                    ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"

                    # Brightness

                    "ALT, XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} -c leds --device \"kbd_backlight\" set +5%"
                    "ALT, XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} -c leds --device \"kbd_backlight\" set 5%-"
                    ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} --device \"apple-panel-bl\" set +5%"
                    ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} --device \"apple-panel-bl\" set 5%-"
                  ]
                  ++ (lib.optionals (cfg.secondarySink != null) ["ALT, XF86AudioRaiseVolume, exec, pactl set-sink-volume ${cfg.secondarySink} +5%" "ALT, XF86AudioLowerVolume, exec, pactl set-sink-volume ${cfg.secondarySink} -5%"]);

                # Move/resize windows with mainMod + LMB/RMB and dragging
                bindm = [
                  "${mainMod}, mouse:272, movewindow"
                  "${mainMod}, mouse:273, resizewindow"
                ];

                layerrule = [
                  "blur on, match:namespace bar-0"
                  "ignore_alpha 0, match:namespace bar-0"
                  "blur on, match:namespace gtk-layer-shell"
                  "ignore_alpha 0, match:namespace gtk-layer-shell"
                  "blur on, match:namespace anyrun"
                  "ignore_alpha 0.2, match:namespace anyrun"
                  "no_anim on, match:namespace anyrun"
                  "blur on, match:namespace notifications"
                  "ignore_alpha 0, match:namespace notifications"

                  "blur on, match:namespace yubikey-state"
                  "ignore_alpha 0.2, match:namespace yubikey-state"

                  "no_anim on, match:namespace selection"
                ];
              }
            ];
        };
      };
    })
  ];
}
