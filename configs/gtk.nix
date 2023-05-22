{
  home = {pkgs, ...}: {
    gtk = {
      enable = true;

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus Dark";
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

    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "Adwaita Dark";
    };
  };
}
