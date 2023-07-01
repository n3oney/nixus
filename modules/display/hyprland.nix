{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkEnableOption mkOption types mkIf;

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

  nullIntOption = mkOption {
    type = types.nullOr types.int;
    default = null;
  };
in {
  options.display = {
    enable = mkEnableOption "Display";

    monitors = {
      main = {
        name = strOption;
        wallpaper = mkOption {
          type = types.path;
        };
        width = intOption;
        height = intOption;
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
    };
  };

  config = lib.mkMerge [
    {
      inputs = {
        hyprland.url = "github:hyprwm/hyprland";
        hyprland.inputs.nixpkgs.follows = "nixpkgs";

        hyprpaper.url = "github:hyprwm/hyprpaper";
        hyprpicker.url = "github:hyprwm/hyprpicker";

        hyprcontrib = {
          url = "github:hyprwm/contrib";
          inputs.nixpkgs.follows = "nixpkgs";
        };

        arrpc = {
          url = "github:notashelf/arrpc-flake";
          inputs.nixpkgs.follows = "nixpkgs";
        };

        shadower.url = "github:n3oney/shadower";
      };
    }
    (mkIf cfg.enable {
      osModules = [inputs.hyprland.nixosModules.default];

      hmModules = [inputs.hyprland.homeManagerModules.default];

      os = {
        programs.hyprland.enable = true;
        xdg.portal.wlr.enable = lib.mkForce false;
      };

      hm = let
        windowSwitchBind = bind: direction: "bind = $mainMod, ${bind}, exec, hyprctl activewindow -j | $(jaq -r \"if .fullscreen then \\\"hyprctl dispatch focusmonitor ${direction}\\\" else \\\"hyprctl dispatch movefocus ${direction}\\\" end\")";

        cursor = {
          package = pkgs.catppuccin-cursors.macchiatoPink;
          name = "Catppuccin-Macchiato-Pink-Cursors";
          size = 24;
        };

        mod = a: b: a - (b * builtins.floor (a / b));
      in {
        home.packages = with pkgs;
        with inputs.hyprcontrib.packages.${pkgs.system};
        with inputs.shadower.packages.${pkgs.system}; [
          pulseaudio

          caprine-bin

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

          (
            writeShellScriptBin
            "history-copy"
            ''
              for file in ~/.mozilla/firefox/*.dev-edition-default/places.sqlite
              do
                   ${pkgs.sqlite}/bin/sqlite3 $file "SELECT rev_host FROM moz_places;" 2>/dev/null | rev | cut -c 2-
              done | sort | uniq -c | sort -nr | awk '{print "https://"$2"/"}' | anyrun -o libstdin.so | wl-copy
            ''
          )
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

          extraConfig = let
            lockSequence = "physlock -ldms && gtklock && physlock -Ld";
          in ''
            exec-once=dbus-update-activation-environment --systemd --all

            monitor=${cfg.monitors.main.name},${toString cfg.monitors.main.width}x${toString cfg.monitors.main.height}@144,0x0,1
            monitor=${cfg.monitors.main.name},addreserved,40,0,0,0
            ${
              if cfg.monitors.secondary.name != null
              then "monitor=${cfg.monitors.secondary.name},${toString cfg.monitors.secondary.width}x${toString cfg.monitors.secondary.height}@60,2560x0,1"
              else ""
            }

            ${
              lib.concatMapStringsSep "\n" (n: "workspace=${toString n},monitor:${cfg.monitors.main.name}") (lib.range 1 10)
            }

            workspace=1,monitor:${cfg.monitors.main.name}, default:true, gapsin:0, gapsout:0, bordersize:1, rounding:false
            workspace=2,monitor:${cfg.monitors.main.name}, default:true

            ${
              if cfg.monitors.secondary.name != null
              then lib.concatMapStringsSep "\n" (n: "workspace=${toString n},monitor:${cfg.monitors.secondary.name}") (lib.range 11 20)
              else ""
            }

            ${
              if cfg.monitors.secondary.name != null
              then "workspace=19,monitor:${cfg.monitors.secondary.name}, default:true, gapsin:0, gapsout:0, bordersize:0, rounding:false"
              else ""
            }

            exec-once=hyprctl setcursor ${cursor.name} ${toString cursor.size}

            exec-once=${lib.getExe pkgs.hyprpaper} & ${pkgs.playerctl}/bin/playerctld & mako
            exec-once=${
              if config.programs.eww.enable
              then "eww daemon && eww open bar && eww open yubikey-state"
              else ""
            }

            # https://wiki.hyprland.org/Configuring/Variables/
            input {

                kb_options = caps:backspace

                # Mouse speed
                accel_profile = flat
                sensitivity = ${toString cfg.mouseSensitivity}
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
              cfg.keyboards
            }

            device:ydotoold-virtual-device-1 {
                sensitivity = 0
            }

            general {
                gaps_in = 8
                gaps_out = 14
                border_size = 2
                col.active_border = rgb(${config.colors.colorScheme.colors.accent})
                col.inactive_border = rgb(2B2937)

                layout = dwindle
            }

            decoration {
                rounding = 12
                blur = yes
                blur_size = 2
                blur_passes = 4
                blur_new_optimizations = on
                drop_shadow = off
                shadow_range = 8
                shadow_render_power = 2
                col.shadow = rgba(1a1a1aff)
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
            windowrulev2 = idleinhibit fullscreen,class:^(.*)$



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
            bind = $mainMod, F1, exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"basic\"") cfg.keyboards}
            bind = $mainMod, F2, exec, ${lib.concatMapStringsSep "; " (n: "hyprctl keyword device:${n}:kb_variant \"colemak_dh_ansi\"") cfg.keyboards}

            # Screenshots
            ${
              if cfg.screenshotKeybinds.active != null
              then "bind = ${cfg.screenshotKeybinds.active}, exec, grimblast save active - | shadower | wl-copy -t image/png && notify-send 'Screenshot taken' --expire-time 1000"
              else ""
            }

            ${
              if cfg.screenshotKeybinds.area != null
              then "bind = ${cfg.screenshotKeybinds.area}, exec, pauseshot | shadower | wl-copy -t image/png && notify-send 'Screenshot taken' --expire-time 1000"
              else ""
            }

            ${
              if cfg.screenshotKeybinds.all != null
              then "bind = ${cfg.screenshotKeybinds.all}, exec, grimblast copy && notify-send 'Screenshot taken' --expire-time 1000"
              else ""
            }

            bind = $mainMod, e, exec, wl-paste | swappy -f - -o - | wl-copy -t image/png && notify-send 'Copied!' --expire-time 1000

            # Volume controls

            binde = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
            binde = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
            bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle

            ${
              if cfg.secondarySink != null
              then ''
                binde = ALT, XF86AudioRaiseVolume, exec, pactl set-sink-volume ${cfg.secondarySink} +5%
                binde = ALT, XF86AudioLowerVolume, exec, pactl set-sink-volume ${cfg.secondarySink} -5%
                bind = ALT, XF86AudioMute, exec, pactl set-sink-mute ${cfg.secondarySink} toggle
              ''
              else ""
            }

            # Music controls

            bind = , XF86AudioPlay, exec, ${lib.getExe pkgs.playerctl} play-pause
            bind = , XF86AudioNext, exec, ${lib.getExe pkgs.playerctl} next
            bind = , XF86AudioPrev, exec, ${lib.getExe pkgs.playerctl} previous

            # Brightness

            binde = , XF86KbdBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} --device "smc::kbd_backlight" set +5%
            binde = , XF86KbdBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} --device "smc::kbd_backlight" set 5%-
            binde = , XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} --device "acpi_video0" set +5%
            binde = , XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} --device "acpi_video0" set 5%-

            bind = $mainMod, h, exec, history-copy

            bind = $mainMod, r, exec, ${lib.getExe pkgs.kooha}

            # Move focus with mainMod + arrow keys
            ${windowSwitchBind "left" "l"}
            ${windowSwitchBind "right" "r"}
            ${windowSwitchBind "up" "u"}
            ${windowSwitchBind "down" "d"}

            # Switch workspaces with mainMod (ALT) + [0-9]
            ${
              lib.concatMapStringsSep "\n" (n: "bind = $mainMod, ${toString (mod n 10)}, workspace, ${toString n}") (lib.range 1 10)
            }

            ${
              if cfg.monitors.secondary.name != null
              then
                lib.concatMapStringsSep "\n" (n: "bind = $mainMod ALT, ${
                  toString (mod (n - 10) 10)
                }, workspace, ${toString n}") (lib.range 11 20)
              else ""
            }

            ${
              lib.concatMapStringsSep "\n" (n: "bind = $mainMod SHIFT, ${toString (mod n 10)}, movetoworkspace, ${toString n}") (lib.range 1 10)
            }

            ${
              if cfg.monitors.secondary.name != null
              then lib.concatMapStringsSep "\n" (n: "bind = $mainMod ALT SHIFT, ${toString (mod (n - 10) 10)}, movetoworkspace, ${toString n}") (lib.range 11 20)
              else ""
            }

            # Move/resize windows with mainMod + LMB/RMB and dragging
            bindm = $mainMod, mouse:272, movewindow
            bindm = $mainMod, mouse:273, resizewindow

            # Text keybindings because why not
            bind = $mainMod , z, exec, sleep 1 && ${lib.getExe pkgs.wtype} " +:hesrightyouknow:" -P Return -p Return

            windowrulev2 = workspace 2,class:firefox

            windowrulev2 = workspace ${
              if cfg.monitors.secondary.name != null
              then "18"
              else "8"
            },class:Caprine

            windowrulev2 = workspace ${
              if cfg.monitors.secondary.name != null
              then "19"
              else "9"
            },class:nheko

            windowrulev2 = workspace ${
              if cfg.monitors.secondary.name != null
              then "19"
              else "9"
            },class:WebCord

            windowrulev2 = forceinput,class:^(fusion360.exe)$
            windowrulev2 = windowdance,class:^(fusion360.exe)$
            windowrulev2 = noanim,title:^(PAUSESHOT)$
            windowrulev2 = fullscreen,title:^(PAUSESHOT)$


            windowrulev2 = nomaxsize,class:^(.*)$

            layerrule = blur,gtk-layer-shell
            layerrule = ignorezero,gtk-layer-shell
            layerrule = blur,anyrun
            layerrule = ignorealpha 0.6,anyrun
            layerrule = blur,notifications
            layerrule = ignorezero,notifications

            layerrule = blur,yubikey-state
            layerrule = ignorealpha 0.6,yubikey-state

            layerrule = noanim, ^(selection)$

            exec-once = firefox &
            exec-once = nheko & webcord &
            exec-once = ${lib.getExe pkgs.caprine-bin} &

            exec-once=${lib.getExe inputs.arrpc.packages.${pkgs.system}.arrpc} &

            exec-once=wlsunset -l 52.2 -L 21 &

            bindl=,switch:off:Lid Switch, exec, ${lockSequence}
            exec-once=swayidle timeout 300 '${lockSequence}' timeout 360 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' timeout 420 'test $(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r ".sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor") -lt 80 && systemctl suspend'

            exec-once=systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland
          '';
        };
      };
    })
  ];
}
