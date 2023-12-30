{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.display;
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

        layer_effects 'bar-0' blur enable; blur_ignore_transparent enable
      '';
    };
  };
}
