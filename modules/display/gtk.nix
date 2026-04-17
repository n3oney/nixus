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
        package = pkgs.kdePackages.breeze-icons;
        name = "breeze-dark";
      };

      theme = {
        package = pkgs.rose-pine-gtk-theme;
        name = "rose-pine";
      };
    };

    home.file.".icons/default/index.theme".text = ''
      [Icon Theme]
      Inherits=breeze_cursors
    '';

    xdg.configFile = {
      kdeglobals.source = "${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors";

      "qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=${pkgs.kdePackages.breeze}/share/color-schemes/BreezeDark.colors
        custom_palette=true
        icon_theme=breeze-dark
        standard_dialogs=xdgdesktopportal
        style=Breeze

        [Fonts]
        fixed="Monospace,9,-1,5,50,0,0,0,0,0"
        general="Sans Serif,9,-1,5,50,0,0,0,0,0"

        [Interface]
        activate_item_on_single_click=1
        buttonbox_layout=0
        cursor_flash_time=1000
        dialog_buttons_have_icons=2
        double_click_interval=400
        keyboard_scheme=2
        menus_have_icons=true
        show_shortcuts_in_context_menus=true
        toolbutton_style=2
        underline_shortcut=1
        wheel_scroll_lines=3

        [Troubleshooting]
        force_raster_widgets=0
      '';
    };

    home.packages = [
      pkgs.kdePackages.breeze
    ];
  };

  config.os = lib.mkIf config.display.enable {
    environment.systemPackages = [
      hmConfig.gtk.theme.package
      pkgs.qt6.qtwayland
      pkgs.kdePackages.breeze
      pkgs.kdePackages.breeze-icons
      pkgs.qt6.qtsvg # needed to load breeze icons
      pkgs.kdePackages.qqc2-desktop-style
      pkgs.kdePackages.kirigami
      pkgs.qt6Packages.qt6ct # patched qt6ct with kiconthemes
    ];

    qt = {
      enable = true;
      platformTheme = "qt5ct";
    };

    environment.variables = let
      qmlPackages = with pkgs; [
        kdePackages.qqc2-desktop-style
        kdePackages.kirigami
        kdePackages.breeze-icons
      ];
      qtVersion = pkgs.kdePackages.qtbase.version;
    in {
      QML2_IMPORT_PATH = lib.concatStringsSep ":" (builtins.map (p: "${p}/lib/qt-${qtVersion}/qml") qmlPackages);
    };

    # Patched qt6ct with kiconthemes support for proper icon theme lookup
    nixpkgs.overlays = [
      (final: prev: {
        qt6Packages = prev.qt6Packages.overrideScope (qfinal: qprev: {
          qt6ct = qprev.qt6ct.overrideAttrs (ctprev: {
            src = pkgs.fetchFromGitLab {
              domain = "www.opencode.net";
              owner = "trialuser";
              repo = "qt6ct";
              rev = "00823e41aa60e8fe266d5aee328e82ad1ad94348";
              sha256 = "sha256-aQmqLpM0vogMsYaDS9OeKVI3N53uY4NBC4FF10hK8Uw=";
            };

            buildInputs =
              ctprev.buildInputs
              ++ (with final.kdePackages; [
                kconfig
                kcolorscheme
                kiconthemes
              ]);
            cmakeFlags = ["-DPLUGINDIR=${placeholder "out"}/lib/qt-6/plugins"];
          });
        });
      })
    ];
  };
}
