{
  config,
  lib,
  pkgs,
  hmConfig,
  ...
}: let
  cfg = config.display;
  hlCfg = hmConfig.wayland.windowManager.hyprland.settings;
in {
  options.display.sway.enable = lib.mkEnableOption "sway";

  config.hm = lib.mkIf cfg.sway.enable {
    wayland.windowManager.sway = {
      package = pkgs.swayfx;
      enable = true;
      config = rec {
        modifier = "Mod4";
        keybindings = let
          workspaces = lib.range 1 10;

          workspaceGoBinds =
            builtins.map (n: {
              name = "${modifier}+${builtins.toString (lib.mod n 10)}";
              value = "workspace number ${builtins.toString n}";
            })
            workspaces;

          workspaceMoveBinds =
            builtins.map (n: {
              name = "${modifier}+Shift+${builtins.toString (lib.mod n 10)}";
              value = "move container to workspace number ${builtins.toString n}; workspace number ${builtins.toString n}";
            })
            workspaces;
        in
          {
            "${modifier}+Return" = "exec foot";
            "${modifier}+W" = "kill";
            "${modifier}+Space" = "exec anyrun";
            "${modifier}+Left" = "focus left";
            "${modifier}+Right" = "focus right";
            "${modifier}+Up" = "focus up";
            "${modifier}+Down" = "focus down";
          }
          // (builtins.listToAttrs workspaceGoBinds)
          // (builtins.listToAttrs workspaceMoveBinds);
        startup = [
          {
            command = "ags";
          }
          {
            command = "hyprpaper";
          }
          {
            command = "${pkgs.autotiling}/bin/autotiling";
          }
        ];

        gaps = {
          smartGaps = true;
          smartBorders = "on";
          inner = 18;
          outer = 2;
        };

        bars = [];

        input = let
          hlDevices = lib.filterAttrs (n: _: lib.hasPrefix "device:" n) hlCfg;
          swayDevices = lib.mapAttrs' (n: v:
            lib.nameValuePair (builtins.substring 7 (builtins.stringLength n) n) ({
                pointer_accel = builtins.toString (v.sensitivity or 0);
              }
              // (
                if v ? kb_layout
                then {xkb_layout = v.kb_layout;}
                else {}
              )
              // (
                if v ? kb_model
                then {xkb_model = v.kb_model;}
                else {}
              )
              // (
                if v ? kb_rules
                then {xkb_rules = v.kb_rules;}
                else {}
              )))
          hlDevices;
        in
          swayDevices
          // {
            "*" = let
              i = hlCfg.input;
            in {
              xkb_options = i.kb_options;
              accel_profile = i.accel_profile;
              pointer_accel = builtins.toString i.sensitivity;
              dwt =
                if i.touchpad.disable_while_typing
                then "enable"
                else "disable";
              drag_lock =
                if i.touchpad.drag_lock
                then "enable"
                else "disable";
              click_method =
                if i.touchpad.clickfinger_behavior
                then "clickfinger"
                else "none";
            };
          };
      };

      extraConfig = ''
        blur enable
        blur_passes 4
        blur_radius 6
        corner_radius 12
        shadows disable

        output ${cfg.monitors.main.name} scale ${toString cfg.monitors.main.scale}
        output ${cfg.monitors.main.name} pos 0 0 res ${toString cfg.monitors.main.width}x${toString cfg.monitors.main.height}

        default_border pixel
        default_floating_border pixel

        ### Layerrule config
        ${builtins.concatStringsSep "\n" (builtins.filter (elem: elem != null) (builtins.map (rule: let
            elems = builtins.split "," rule;
            layer = builtins.elemAt elems 2;
            hlRule = builtins.elemAt elems 0;

            swayRule =
              {
                blur = "blur";
                ignorezero = "blur_ignore_transparent";
                ignorealpha = "blur_ignore_transparent";
                noanim = null;
              }
              ."${builtins.elemAt (builtins.split " " hlRule) 0}";
          in (
            if swayRule == null
            then null
            else "layer_effects '${layer}' ${swayRule} enable"
          ))
          hlCfg.layerrule))}
      '';
    };
  };
}
