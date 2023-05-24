{
  home = {
    pkgs,
    config,
    lib,
    ...
  }: {
    services.dunst = {
      enable = true;

      settings = with lib;
      with builtins; let
        background = "#${config.programs.foot.settings.colors.background}${toHexString (floor (config.programs.foot.settings.colors.alpha * 255))}";
        foreground = "#${config.programs.foot.settings.colors.foreground}";
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
          frame_color = "#${config.colorScheme.colors.base03}";
        };

        urgency_normal = {
          inherit background foreground;
          frame_color = "#${config.colorScheme.colors.accent}";
        };

        urgency_critical = {
          inherit background foreground;
          frame_color = "#${config.colorScheme.colors.base08}";
        };
      };
    };
  };
}
