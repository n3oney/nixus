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
          accents = ["green"];
          tweaks = ["rimless"];
          variant = "mocha";
        };
        name = "Catppuccin-Mocha-Standard-Green-Dark";
      };
    };

    qt = {
      enable = true;
      platformTheme = "gtk";
      style.name = "Adwaita Dark";
    };
  };
}
