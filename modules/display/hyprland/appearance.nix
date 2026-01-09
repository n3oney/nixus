{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.display;

  cursor = {
    package = pkgs.catppuccin-cursors.macchiatoTeal;
    name = "catppuccin-macchiato-teal-cursors";
    size = 24;
  };
in {
  config = lib.mkIf cfg.enable {
    hm.home.pointerCursor = {
      gtk.enable = true;
      inherit (cursor) name;
      inherit (cursor) package;
      inherit (cursor) size;
      x11 = {
        defaultCursor = cursor.name;
        enable = true;
      };
    };

    hm.wayland.windowManager.hyprland.settings = {
      exec-once = [
        "hyprctl setcursor ${cursor.name} ${toString cursor.size}"
      ];

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
          "workspaces, 1, 7, fluent_decel, slide"
          "specialWorkspace, 1, 3, md3_decel, slidevert"
        ];
      };
    };
  };
}
