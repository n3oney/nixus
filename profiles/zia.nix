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
        bluetooth
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
          mainMonitor = "eDP-1";
          mainWidth = 1440;
          mainHeight = 900;
          mainWallpaper = ../wallpapers/cherry/laptop.png;
          mouseSensitivity = 0;

          keyboards = [
            "apple-inc.-apple-internal-keyboard-/-trackpad"
            "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
            "logitech-usb-receiver-keyboard"
          ];

          activeScreenshotKeybind = ", XF86LaunchA";
          areaScreenshotKeybind = "SHIFT, XF86LaunchA";
          allScreenshotKeybind = ", XF86LaunchB";

          termFontSize = 7;
        })
        kde_connect
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
        swappy
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
