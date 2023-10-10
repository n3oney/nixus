{
  config,
  pkgs,
  lib,
  ...
}: {
  config.hm = lib.mkIf config.display.enable {
    gtk = {
      enable = true;

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      theme = {
        package = pkgs.catppuccin-gtk.override {
          accents = ["pink"];
          tweaks = ["rimless"];
          variant = "macchiato";
        };
        name = "Catppuccin-Macchiato-Standard-Pink-Dark";
      };
    };
  };

  config.os.qt = lib.mkIf config.display.enable {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };
}
