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
  };
}
