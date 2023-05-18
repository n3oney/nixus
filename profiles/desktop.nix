mkSystem: let
  username = "neoney";
in
  mkSystem {
    inherit username;
    args = {};
  } {
    configs = cfgs:
      with cfgs; [
        nix
        fish
        anyrun
        discord
        eww
        firefox
        fonts
        foot
        gaming
        git
        gpg
        gtk
        keyring
        lockscreen
        login
        neovim
        nheko
        notifications
        nur
        packages
        pkgs
        poweroff
        ssh
        starship
        (hyprland {
          mainMonitor = "DP-1";
          mainWidth = 2560;
          mainHeight = 1440;
          secondaryMonitor = "DP-3";
          mainWallpaper = ../wallpapers/Kanagawa.jpg;
          secondaryWallpaper = ../wallpapers/Kanagawa.jpg;
          mouseSensitivity = -0.76;
          keyboards = [
            "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
            "logitech-usb-receiver-keyboard"
          ];
          activeScreenshotKeybind = ", Print";
          areaScreenshotKeybind = "SHIFT, Print";
          allScreenshotKeybind = "ALT, Print";
          termFontSize = 7;
          serifFont = "New York";
          monoFont = "Cozette";
          sansFont = "gg sans";
          windows = true;
          activeBorder = "F5F4F9";
          inactiveBorder = "2B2937";
          secondarySink = "raop_sink.raspberrypi.local.ipv4";
        })
        youtube-tv
      ];

    system = {pkgs, ...}: {
      time.timeZone = "Europe/Warsaw";
      i18n.defaultLocale = "en_US.UTF-8";

      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        wget
        libnotify
        ripgrep
      ];
    };
  }
