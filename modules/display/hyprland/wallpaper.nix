{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.display;
  wallpaper = ../../../wallpapers/ios13.jpg;
  awwwPkg = inputs.awww.packages.${pkgs.system}.default;
  inherit (lib) mkIf mkEnableOption;
in {
  config = mkIf cfg.enable {
    # Home Manager packages
    hm.home.packages = [ awwwPkg ];

    # Hyprland exec-once command
    hm.wayland.windowManager.hyprland.settings.exec-once = [
      ''awww-daemon && sleep 1 && awww img ${wallpaper} --transition-type fade''
    ];
  };
}
