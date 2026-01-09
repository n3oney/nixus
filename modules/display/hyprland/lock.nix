{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
  accent = config.colors.colorScheme.palette.accent;
in {
  config = mkIf cfg.enable {
    # NixOS module for PAM integration
    os.programs.hyprlock.enable = true;

    # Home Manager module for settings
    hm.programs.hyprlock = {
      enable = true;
      settings = {
        "$font" = "MonoLisa";

        general = {
          immediate_render = true;
          hide_cursor = true;
        };

        animations = {
          enabled = true;
          bezier = "linear, 1, 1, 0, 0";
          animation = [
            "fadeIn, 1, 5, linear"
            "fadeOut, 1, 5, linear"
            "inputFieldDots, 1, 2, linear"
          ];
        };

        background = [
          {
            monitor = "";
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        input-field = [
          {
            monitor = "";
            size = "20%, 5%";
            outline_thickness = 3;
            inner_color = "rgba(0, 0, 0, 0.0)";

            outer_color = "rgba(${accent}ee) rgba(${accent}88) 45deg";
            check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
            fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

            font_color = "rgb(200, 200, 200)";
            fade_on_empty = false;
            rounding = 15;

            font_family = "$font";
            placeholder_text = "Input password...";
            fail_text = "$PAMFAIL";

            dots_spacing = 0.3;
            dots_center = true;

            position = "0, -20";
            halign = "center";
            valign = "center";

            shadow_passes = 2;
          }
        ];

        # Time
        label = [
          {
            monitor = "";
            text = "$TIME";
            font_size = 90;
            font_family = "$font";

            color = "rgb(200, 200, 200)";

            position = "-30, 0";
            halign = "right";
            valign = "top";

            shadow_passes = 2;
          }
          # Date
          {
            monitor = "";
            text = "cmd[update:60000] date +\"%A, %d %B %Y\"";
            font_size = 25;
            font_family = "$font";

            color = "rgb(200, 200, 200)";

            position = "-30, -150";
            halign = "right";
            valign = "top";

            shadow_passes = 1;
          }
          # Keyboard layout
          {
            monitor = "";
            text = "$LAYOUT[!,pl]";
            font_size = 24;
            font_family = "$font";

            color = "rgb(200, 200, 200)";

            onclick = "hyprctl switchxkblayout all next";

            position = "250, -20";
            halign = "center";
            valign = "center";
          }
        ];
      };
    };
  };
}
