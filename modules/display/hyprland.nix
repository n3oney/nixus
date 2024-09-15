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

  # don't ask
  uwunix = ''
    ✨ Nix-chan's Sugoi Advantages! ✨

    * Evewyfing packaged juuuust wight, onii-chan! No mowie missing stuffies! >.<
    * Nix-chan nevew changes up da wesults! Uwu can always count on it! 💖
    * Supew easy to buiwd stuffies! Onii-chan, you'we da smartestest!
    * Change package fingies wifout icky stuffies! Souwce-based is bestest!
    * One package managew to bwing dem all! Wikey...magic stuffies! >w<
    * Switching dev stuffies is a bweezy wif dat diwenv fingy!
    * Twy out packages wifout icky stuffies behind! nix shell is a wifesaver!
    * Scipts can do ANYFINGY! Nix-chan wiww fetch da goodies, no sweaties! 💦
    * Binawy caches mean wessie waiting... Nix-chan hates compiwing too! >.<
    * Setting up caches is easy peasy! Even a baka wike me can do it!
    * Wemote buiwding? Dat's... amazwing! Testy-testy fwuffy-wuffy!
    * It wuns on Winuxy fingies AND da fwuity OS! Sugoi desu! ✨
    * Nix-chan can wun all by hersewf! Mixing packages wifout bweaking? Yes pwease! 🥺👉👈
    * Fwakes...dey sound impowtant! Pinning vewsions...smawtie pants!

    🌟 NixOS makes my heart go doki-doki! 🌟

    * Uwu teww NixOS wat chu wantie, and poofie! It just happens! Wikey a wishie! 💫
    * Easy to change stuffies up, ow fix boo-boos... >.<
    * Shawe youw setup wif fwiends, onii-chan! Dey'ww fink you'we a hewo!
    * Depwoying stuffies is a snappy! Wollbacks awe da bestest!
    * Sooo many optionsies! Wikey, evewyfingy I couwd evew wantie!
    * No nasty side effects... It's like magic cweaning poofies!
    * VMs wif bawely any effowtsies... Onii-chan, you'we a genius!
    * Fwiends can twy my set up too! It's da coolestest!
  '';

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
        wallpaper = mkOption {
          type = types.path;
        };
        width = intOption;
        height = intOption;
        scale = floatOption // {default = 1.0;};
        refreshRate = intOption // {default = 60;};
      };
      secondary = {
        name = nullStrOption;
        wallpaper = mkOption {
          type = types.nullOr types.path;
          default = null;
        };
        width = nullIntOption;
        height = nullIntOption;
      };
    };

    binds = mkOption {
      default =
        [
          (mkBind "${mainMod}, Return" "exec, foot" "Launch terminal")
          (mkBind "${mainMod}, W" "killactive," "Close focused window")
          (mkBind "${mainMod}, M" "exit," "Close Hyprland")
          (mkBind "${mainMod}, P" "exec, hyprpicker -a" "Open color picker")
          (mkBind "${mainMod}, S" "togglefloating," "Toggle floating")
          (mkBind "${mainMod}, space" "exec, anyrun" "Open application launcher")
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
          (mkBind "${mainMod} , n" ''exec, echo -e "${builtins.replaceStrings ["\"" "\n"] ["\\\"" "\\n"] uwunix}" | wl-copy'' "i love nixos")

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
        environment.sessionVariables.NIXOS_OZONE_WL = "1";
        nixpkgs.overlays = [inputs.hyprland.overlays.default];

        programs.hyprland = {
          enable = true;
          package = cfg.package;
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
          pulseaudio

          # caprine-bin

          wl-clipboard

          hyprpaper

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

          (writeShellScriptBin
            "pauseshot"
            ''
              ${hyprpicker}/bin/hyprpicker -r -z &
              picker_proc=$!

              ${grimblast}/bin/grimblast save area -

              kill $picker_proc
            '')
        ];

        home.pointerCursor = {
          gtk.enable = true;
          name = cursor.name;
          package = cursor.package;
          size = cursor.size;
          x11 = {
            defaultCursor = cursor.name;
            enable = true;
          };
        };

        xdg.configFile."hypr/hyprpaper.conf".text = ''
          preload=${cfg.monitors.main.wallpaper}
          ${
            if cfg.monitors.secondary.wallpaper != null
            then "preload=${cfg.monitors.secondary.wallpaper}"
            else ""
          }

          wallpaper = ${cfg.monitors.main.name},${cfg.monitors.main.wallpaper}
          ${
            if (cfg.monitors.secondary.name != null && cfg.monitors.secondary.wallpaper != null)
            then "wallpaper = ${cfg.monitors.secondary.name},${cfg.monitors.secondary.wallpaper}"
            else ""
          }
        '';

        wayland.windowManager.hyprland = {
          enable = true;

          package = cfg.package;

          settings = let
            lockSequence = "physlock -ldms && ${lib.getExe pkgs.swaylock} && physlock -Ld";
          in
            lib.mkMerge [
              {
                exec-once =
                  [
                    "dbus-update-activation-environment --systemd --all"
                    "hyprctl setcursor ${cursor.name} ${toString cursor.size}"
                    "${lib.getExe pkgs.hyprpaper} & ${pkgs.playerctl}/bin/playerctld & mako"

                    "zen-browser &"
                    "${lib.getExe config.programs.discord.finalPackage} &"
                    "cinny &"
                    # "${lib.getExe pkgs.caprine-bin} &"

                    "${lib.getExe inputs.arrpc.packages.${pkgs.system}.arrpc} &"

                    "wlsunset -l 52.2 -L 21 &"

                    ''${lib.getExe pkgs.xss-lock} --ignore-sleep -- ${lib.getExe pkgs.bash} -c ${builtins.toJSON lockSequence}''

                    ''swayidle timeout 300 '${lockSequence}' timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 420 'test $(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r ".sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor") -lt 80 && systemctl suspend' ''

                    "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
                  ]
                  ++ (lib.optionals config.programs.ags.enable ["ags"]);

                monitor =
                  [
                    "${cfg.monitors.main.name},${toString cfg.monitors.main.width}x${toString cfg.monitors.main.height}@${toString cfg.monitors.main.refreshRate},0x0,${toString cfg.monitors.main.scale}"
                  ]
                  ++ (lib.optionals (cfg.monitors.secondary.name != null) ["monitor=${cfg.monitors.secondary.name},${toString cfg.monitors.secondary.width}x${toString cfg.monitors.secondary.height}@60,2560x0,1"]);

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
                  ];
                input = {
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

                device =
                  [
                    {
                      name = "glorious-model-o-wireless";
                      sensitivity = -0.76;
                    }
                    {
                      name = "ydotoold-virtual-device-1";
                      sensitivity = 0;
                    }
                  ]
                  ++ (builtins.map (keyboard: {
                      name = keyboard;
                      kb_layout = "pl";
                    })
                    cfg.keyboards);

                gestures = {
                  workspace_swipe = true;
                };

                misc = {
                  disable_hyprland_logo = true;
                  vfr = true;
                  vrr = true;
                };

                env = lib.mkIf cfg.enableTearing ["AQ_DRM_NO_ATOMIC,1"];

                general = {
                  allow_tearing = cfg.enableTearing;
                  gaps_in = 8;
                  gaps_out = 14;
                  border_size = 2;
                  "col.active_border" = "rgb(${config.colors.colorScheme.colors.accent})";
                  "col.inactive_border" = "rgb(2B2937)";

                  layout = "dwindle";
                };

                decoration = {
                  rounding = 20;

                  drop_shadow = true;
                  shadow_ignore_window = true;
                  shadow_range = 20;
                  shadow_render_power = 2;
                  shadow_offset = "0 2";
                  "col.shadow" = "rgba(0000001A)";

                  dim_special = 0.6;

                  blur = {
                    enabled = true;
                    size = 5;
                    passes = 4;
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
                  no_gaps_when_only = true;
                  pseudotile = true;
                  preserve_split = true;
                };

                windowrulev2 = [
                  "immediate,class:^(cs2)$"
                  "suppressevent fullscreen,class:^(cs2)$"
                  "suppressevent maximize,class:^(cs2)$"
                  "immediate,class:^(Minecraft.*)$"
                  "noblur,class:^(Xdg-desktop-portal-gtk)$"
                  "pin,class:^(ssh-askpass)$"
                  "float,class:^(ssh-askpass)$"
                  "idleinhibit focus,title:^(YouTube on TV.*)$"
                  "idleinhibit fullscreen,class:^(.*)$"
                  "float,class:^([Ww]aydroid.*)$"

                  "workspace 2,class:zen-alpha"

                  "rounding 0,workspace:1,floating:0"
                  "bordersize 1,workspace:1,floating:0"

                  "rounding 0,workspace:${
                    toString (
                      if cfg.monitors.secondary.name != null
                      then 19
                      else 9
                    )
                  },floating:0"
                  "bordersize 1,workspace:${
                    toString (
                      if cfg.monitors.secondary.name != null
                      then 19
                      else 9
                    )
                  },floating:0"

                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "18"
                    else "8"
                  },class:Caprine"

                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "19"
                    else "9"
                  },class:cinny"

                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "19"
                    else "9"
                  },class:vesktop"
                  "opacity 0.999,class:vesktop"

                  "workspace ${
                    if cfg.monitors.secondary.name != null
                    then "20"
                    else "10"
                  }, class:^(YouTube Music)$"

                  "noanim,title:^(PAUSESHOT)$"
                  "fullscreen,title:^(PAUSESHOT)$"

                  "nomaxsize,class:^(.*)$"
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
                  "blur,bar-0"
                  "ignorezero,bar-0"
                  "blur,gtk-layer-shell"
                  "ignorezero,gtk-layer-shell"
                  "blur,anyrun"
                  "ignorealpha 0.6,anyrun"
                  "blur,notifications"
                  "ignorezero,notifications"

                  "blur,yubikey-state"
                  "ignorealpha 0.6,yubikey-state"

                  "noanim,selection"
                ];
              }
            ];
        };
      };
    })
  ];
}
