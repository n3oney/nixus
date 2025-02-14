{
  pkgs,
  config,
  lib,
  ...
}: {
  config.hm = lib.mkIf config.display.enable {
    services.dunst = {
      enable = true;

      settings = with lib;
      with builtins; let
        background = "#${config.colors.colorScheme.palette.base00}${toHexString (floor (config.colors.backgroundAlpha * 255))}";
        foreground = "#${config.colors.colorScheme.palette.base05}";
      in {
        global = {
          monitor = 1;
          follow = "none";
          width = 300;
          height = 300;
          origin = "top-right";
          offset = "10x50";

          notification_limit = 20;

          frame_width = 2;
          gap_size = 10;

          idle_threshold = 32;

          font = "sans";

          browser = "${pkgs.xdg-utils}/bin/xdg-open";

          corner_radius = 14;
        };

        urgency_low = {
          inherit background foreground;
          frame_color = "#${config.colors.colorScheme.palette.base03}";
        };

        urgency_normal = {
          inherit background foreground;
          frame_color = "#${config.colors.colorScheme.palette.accent}";
        };

        urgency_critical = {
          inherit background foreground;
          frame_color = "#${config.colors.colorScheme.palette.base08}";
        };
      };
    };
  };
}
