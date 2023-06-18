mkSystem: let
  username = "neoney";
in
  mkSystem {
    inherit username;
    args = {};
  } {
    configs = cfgs:
      with cfgs; [
        discord
        eww
        (youtube-tv {})

        anyrun
        btop
        colors
        firefox
        fish
        fonts
        foot
        # gaming
        git
        gpg
        gtk
        helix
        (hyprland {
          mainMonitor = "DP-1";
          mainWidth = 1440;
          mainHeight = 900;
          # secondaryMonitor = "DP-3";
          mainWallpaper = ../wallpapers/cherry/laptop.png;
          # secondaryWallpaper = ../wallpapers/cherry/secondary.png;

          mouseSensitivity = -0.76;

          # TODO: Add builtin keyboard
          keyboards = [
            "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
            "logitech-usb-receiver-keyboard"
          ];

          # TODO: Use media keys
          activeScreenshotKeybind = ", Print";
          areaScreenshotKeybind = "SHIFT, Print";
          allScreenshotKeybind = "ALT, Print";

          termFontSize = 7;
          # secondarySink = "raop_sink.raspberrypi.local.192.168.1.4.5000";
        })
        # kde_connect
        keyring
        lockscreen
        login
        # neovim
        nheko
        nix
        notifications
        nur
        (openrgb {motherboard = "intel";})
        packages
        pkgs
        # podman
        poweroff
        secrets
        ssh
        starship
        thunderbird
        yubikey-touch-detector
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
