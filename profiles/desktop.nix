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
        colors
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
        podman
        poweroff
        ssh
        starship
        (hyprland {
          mainMonitor = "DP-1";
          mainWidth = 2560;
          mainHeight = 1440;
          secondaryMonitor = "DP-3";
          mainWallpaper = ../wallpapers/cherry/primary.png;
          secondaryWallpaper = ../wallpapers/cherry/secondary.png;
          mouseSensitivity = -0.76;
          keyboards = [
            "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
            "logitech-usb-receiver-keyboard"
          ];
          activeScreenshotKeybind = ", Print";
          areaScreenshotKeybind = "SHIFT, Print";
          allScreenshotKeybind = "ALT, Print";
          termFontSize = 7;
          secondarySink = "raop_sink.raspberrypi.local.192.168.1.4.5000";
        })
        kde_connect
        (youtube-tv {
          secondarySink = "raop_sink.raspberrypi.local.ipv4";
        })
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
