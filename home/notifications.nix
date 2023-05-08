{pkgs, ...}: {
  services.dunst = {
    enable = true;

    settings = {
      global = {
        monitor = 1;
        follow = "none";
        width = 300;
        height = 300;
        origin = "top-right";
        offset = "10x50";

        notification_limit = 20;

        frame_width = 2;
        frame_color = "#a6e3a1";
        gap_size = 10;

        idle_threshold = 32;

        font = "sans";

        browser = "${pkgs.xdg-utils}/bin/xdg-open";

        corner_radius = 14;
      };

      urgency_low = {
        background = "#18182580";
        foreground = "#cdd6f4";
      };

      urgency_normal = {
        background = "#181825";
        foreground = "#cdd6f4";
      };

      urgency_critical = {
        background = "#181825";
        foreground = "#cdd6f4";
        frame_color = "#f38ba8";
      };
    };
  };
}
