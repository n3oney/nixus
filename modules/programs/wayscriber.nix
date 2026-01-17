{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.wayscriber;
  tomlFormat = pkgs.formats.toml {};
in {
  options.wayscriber.enable = lib.mkEnableOption "Wayscriber";

  config = lib.mkIf cfg.enable (let
    package = inputs.wayscriber.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    applications.wayscriber = {
      autostart = true;
      binaryPath = "${package}/bin/wayscriber -d";
      type = "daemon";
    };

    hm = {
      home.packages = [package];

      xdg.configFile."wayscriber/config.toml".source = tomlFormat.generate "wayscriber-config" {
        performance = {
          buffer_count = 2;
          enable_vsync = true;
        };
        tablet = {
          enabled = true;
          pressure_enabled = true;
          min_thickness = 1.0;
          max_thickness = 8.0;
        };
      };

      wayland.windowManager.hyprland.settings.bind = [
        "SUPER SHIFT, XF86TouchpadToggle, exec, pkill -SIGUSR1 wayscriber"
      ];
    };
  });
}
