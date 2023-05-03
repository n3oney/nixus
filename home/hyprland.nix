{
  pkgs,
  lib,
  utils,
  vars,
  inputs,
  ...
}: let
  windowSwitchBind = bind: direction: "bind = $mainMod, ${bind}, exec, hyprctl activewindow -j | $(jaq -r \"if .fullscreen then \\\"hyprctl dispatch focusmonitor ${direction}\\\" else \\\"hyprctl dispatch movefocus ${direction}\\\" end\")";

  cursor = {
    package = pkgs.catppuccin-cursors.mochaGreen;
    name = "Catppuccin-Mocha-Green-Cursors";
    size = 24;
  };
in
  with vars; {
    home.packages = with pkgs; [
      wl-clipboard

      hyprpaper

      ydotool

      wlsunset

      hyprpicker
      grimblast

      swayidle
      swaylock
      physlock

      sysstat

      jaq

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
      preload=${main_wallpaper}
      ${
        if vars ? secondary_wallpaper
        then "preload=${secondary_wallpaper}"
        else ""
      }

      wallpaper = ${main_monitor},${main_wallpaper}
      ${
        if vars ? secondary_monitor
        then "wallpaper = ${secondary_monitor},${secondary_wallpaper}"
        else ""
      }
    '';

    services.kdeconnect.enable = true;

    wayland.windowManager.hyprland = {
      enable = true;

      disableAutoreload = true;

      extraConfig = ''
        exec-once=${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all

        monitor=${main_monitor},${toString main_width}x${toString main_height}@144,0x0,1
        monitor=${main_monitor},addreserved,40,0,0,0
        ${
          if vars ? secondary_monitor
          then "monitor=${secondary_monitor},1920x1080@60,2560x0,1"
          else ""
        }

        workspace=2,${main_monitor}
        ${
          if vars ? secondary_monitor
          then "workspace=19,${secondary_monitor}"
          else ""
        }

        ${
          lib.concatMapStringsSep "\n" (n: "wsbind=${toString n},${main_monitor}") (lib.range 1 10)
        }

        ${
          if vars ? secondary_monitor
          then lib.concatMapStringsSep "\n" (n: "wsbind=${toString n},${secondary_monitor}") (lib.range 11 20)
          else ""
        }

        exec-once=hyprctl setcursor ${cursor.name} ${toString cursor.size}

        exec-once=${lib.getExe pkgs.hyprpaper} & playerctld & mako
        exec-once=eww daemon && eww open bar

        # https://wiki.hyprland.org/Configuring/Variables/
        input {

            kb_options = caps:backspace

            # Mouse speed
            accel_profile = flat
            sensitivity = ${toString mouse_sensitivity}
            follow_mouse = 1

            touchpad {
              disable_while_typing = false
              drag_lock = true
              clickfinger_behavior = true
            }
        }

        device:glorious-model-o-wireless {
                sensitivity = -0.76
        }

        gestures {
          workspace_swipe = true
        }

        misc {
          disable_hyprland_logo = true
          vfr = true
          vrr = 1
        }

        ${
          lib.concatMapStringsSep "\n" (n: ''
            device:${n} {
                kb_layout = pl
                kb_model =
                kb_rules =
            }
          '')
          keyboards
        }

        device:ydotoold-virtual-device-1 {
            sensitivity = 0
        }

        general {
            gaps_in = 8
            gaps_out = 14
            border_size = 2
            col.active_border = rgb(${active_border})
            col.inactive_border = rgb(${inactive_border})

            layout = dwindle
        }

        decoration {
            rounding = 12
            blur = yes
            blur_size = 2
            blur_passes = 4
            blur_new_optimizations = on
        }

        animations {
            enabled = yes

            # https://wiki.hyprland.org/Configuring/Animations/
            animation = windows, 1, 3, default
            animation = windowsOut, 1, 3, default, popin 80%
            animation = border, 1, 3, default
            animation = fade, 1, 4, default
            animation = workspaces, 1, 4, default, slide
        }

        dwindle {
            no_gaps_when_only = yes
            pseudotile = yes
            preserve_split = yes
        }

        windowrulev2 = pin,class:^(ssh-askpass)$
        windowrulev2 = float,class:^(ssh-askpass)$

        windowrulev2 = idleinhibit focus,title:^(YouTube on TV.*)$



        # See https://wiki.hyprland.org/Configuring/Keywords/ for more
        $mainMod = SUPER

        bind = $mainMod, Return, exec, foot
        bind = $mainMod, W, killactive,
        bind = $mainMod, M, exit,
        bind = $mainMod, P, exec, hyprpicker -a
        bind = $mainMod, S, togglefloating,
        bind = $mainMod, space, exec, anyrun
        bind = $mainMod, T, togglesplit, # dwindle

        bind = $mainMod, Q, togglespecialworkspace,

        bind = $mainMod, F, fullscreen,


        # Keyboard layouts
        bind = $mainMod, F1, exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"basic\"") keyboards}
        bind = $mainMod, F2, exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"colemak_dh_ansi\"") keyboards}

        # Screenshots
        ${
          if vars ? active_screenshot_keybind
          then "bind = ${active_screenshot_keybind}, exec, grimblast save active - | wl-copy -t image/png && notify-send 'Screenshot taken' --expire-time 1000"
          else ""
        }

        ${
          if vars ? area_screenshot_keybind
          then "bind = ${area_screenshot_keybind}, exec, grimblast save area - | wl-copy -t image/png && notify-send 'Screenshot taken' --expire-time 1000"
          else ""
        }

        ${
          if vars ? all_screenshot_keybind
          then "bind = ${all_screenshot_keybind}, exec, grimblast copy && notify-send 'Screenshot taken' --expire-time 1000"
          else ""
        }

        bind = $mainMod, e, exec, wl-paste | swappy -f - -o - | wl-copy -t image/png && notify-send 'Copied!' --expire-time 1000

        # Volume controls

        binde = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
        binde = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
        bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle

        ${
          if vars ? secondary_sink
          then ''
            binde = ALT, XF86AudioRaiseVolume, exec, pactl set-sink-volume ${secondary_sink} +5%
            binde = ALT, XF86AudioLowerVolume, exec, pactl set-sink-volume ${secondary_sink} -5%
            bind = ALT, XF86AudioMute, exec, pactl set-sink-mute ${secondary_sink} toggle
          ''
          else ""
        }

        # Music controls

        bind = , XF86AudioPlay, exec, playerctl play-pause
        bind = , XF86AudioNext, exec, playerctl next
        bind = , XF86AudioPrev, exec, playerctl previous

        # Brightness

        binde = , XF86KbdBrightnessUp, exec, xbacklight -ctrl "smc::kbd_backlight" -inc 5
        binde = , XF86KbdBrightnessDown, exec, xbacklight -ctrl "smc::kbd_backlight" -dec 5
        binde = , XF86MonBrightnessUp, exec, xbacklight -ctrl "intel_backlight" -inc 5
        binde = , XF86MonBrightnessDown, exec, xbacklight -ctrl "intel_backlight" -dec 5


        # Move focus with mainMod + arrow keys
        ${windowSwitchBind "left" "l"}
        ${windowSwitchBind "right" "r"}
        ${windowSwitchBind "up" "u"}
        ${windowSwitchBind "down" "d"}

        # Switch workspaces with mainMod (ALT) + [0-9]
        ${
          lib.concatMapStringsSep "\n" (n: "bind = $mainMod, ${toString (utils.mod n 10)}, workspace, ${toString n}") (lib.range 1 10)
        }

        ${
          if vars ? secondary_monitor
          then
            lib.concatMapStringsSep "\n" (n: "bind = $mainMod ALT, ${
              toString (utils.mod (n - 10) 10)
            }, workspace, ${toString n}") (lib.range 11 20)
          else ""
        }

        ${
          lib.concatMapStringsSep "\n" (n: "bind = $mainMod SHIFT, ${toString (utils.mod n 10)}, movetoworkspace, ${toString n}") (lib.range 1 10)
        }

        ${
          if vars ? secondary_monitor
          then lib.concatMapStringsSep "\n" (n: "bind = $mainMod ALT SHIFT, ${toString (utils.mod (n - 10) 10)}, movetoworkspace, ${toString n}") (lib.range 11 20)
          else ""
        }

        bind = ,F7,pass,^(com\.obsproject\.Studio)$

        # workspace=DP-1,2
        # workspace=DP-3,19

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow


        # Text keybindings because why not
        bind = $mainMod , z, exec, sleep 1 && echo "+:hesrightyouknow:" | ydotool type -d 0 -H 2 -f -

        windowrulev2 = workspace 2,class:firefox

        windowrulev2 = workspace ${
          if vars ? secondary_monitor
          then "18"
          else "8"
        },class:caprine
        windowrulev2 = workspace ${
          if vars ? secondary_monitor
          then "19"
          else "9"
        },class:WebCord

        windowrulev2 = forceinput,class:^(fusion360.exe)$
        windowrulev2 = windowdance,class:^(fusion360.exe)$
        windowrulev2 = noanim,title:^(PAUSESHOT)$
        windowrulev2 = fullscreen,title:^(PAUSESHOT)$

        layerrule = blur,gtk-layer-shell
        layerrule = blur,anyrun
        layerrule = ignorezero,gtk-layer-shell

        layerrule = noanim, ^(selection)$

        exec-once = hyprctl dispatch moveworkspacetomonitor 2 ${main_monitor}

        exec-once = firefox &
        exec-once = webcord &

        exec-once=${lib.getExe inputs.arrpc.packages.${pkgs.system}.arrpc} &

        exec-once=wlsunset -l 52.2 -L 21 &

        exec-once=ydotoold &

        exec-once=swayidle timeout 300 'physlock -ldms && swaylock && physlock -Ld' timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 420 'test $(mpstat -o JSON 1 3 | jqq -r ".sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor") -lt 80 && systemctl suspend'
      '';
    };
  }
