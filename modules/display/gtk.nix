{
  config,
  pkgs,
  lib,
  hmConfig,
  ...
}: {
  config.hm = lib.mkIf config.display.enable {
    gtk = {
      enable = true;

      iconTheme = {
        # package = pkgs.papirus-icon-theme;
        # name = "Papirus-Dark";
        package = pkgs.rose-pine-icon-theme;
        name = "rose-pine";
      };

      theme = {
        # package = pkgs.catppuccin-gtk.override {
        # accents = ["pink"];
        # tweaks = ["rimless"];
        # variant = "macchiato";
        # };
        # name = "Catppuccin-Macchiato-Standard-Pink-Dark";
        package = pkgs.rose-pine-gtk-theme;
        name = "rose-pine";
      };
    };

    home.file.".icons/default/index.theme".text = ''
      [Icon Theme]
      inherits=breeze_cursors
    '';

    xdg.configFile = {
      kdeglobals.source = "${pkgs.libsForQt5.breeze-qt5}/share/color-schemes/BreezeDark.colors";

      "qt5ct/qt5ct.conf".text = ''
        [Appearance]
        style=Lightly
        icon_theme=Papirus-Dark
        custom_palette=true
        color_scheme_path=${pkgs.catppuccin-qt5ct}/share/qt5ct/colors/Catppuccin-Macchiato.conf

        [Fonts]
        fixed="Monospace,9,-1,5,50,0,0,0,0,0"
        general="Sans Serif,9,-1,5,50,0,0,0,0,0"
      '';
    };
  };

  config.os = lib.mkIf config.display.enable {
    environment.systemPackages =
      [
        # Make the GTK theme available for other users
        hmConfig.gtk.theme.package
      ]
      ++ (with pkgs; [
        libsForQt5.qt5ct
        lightly-qt
      ]);

    environment.variables = let
      qmlPackages = with pkgs; [
        plasma5Packages.qqc2-desktop-style
        plasma5Packages.kirigami2
      ];
      qtVersion = pkgs.qt515.qtbase.version;
    in {
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QML2_IMPORT_PATH = lib.concatStringsSep ":" (builtins.map (p: "${p}/lib/qt-${qtVersion}/qml") qmlPackages);
    };
  };
}
