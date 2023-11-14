{pkgs, ...}: {
  users.main = "neoney";

  display = {
    enable = true;

    monitors = {
      main = {
        name = "eDP-1";
        wallpaper = ../../wallpapers/cherry/laptop.png;
        width = 1440;
        height = 900;
      };
    };

    keyboards = [
      "apple-inc.-apple-internal-keyboard-/-trackpad"
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
    ];
    mouseSensitivity = 0.00;

    screenshotKeybinds = {
      active = ", XF86LaunchA";
      area = "SHIFT, XF86LaunchA";
      all = ", XF86LaunchB";
    };
  };

  programs = {
    anyrun.enable = true;
    btop.enable = true;
    discord.enable = true;
    eww = {
      enable = true;
      micName = "Built-in Audio Analog Stereo";
    };
    firefox.enable = true;
    foot.enable = true;
    swappy.enable = true;
    thunderbird.enable = true;
    gaming = {
      steam = {
        enable = true;
        proton-ge.enable = true;
      };
    };
    jellyfinPlayer.enable = true;
    youtube-music.enable = true;
  };

  services = {
    yubikey-touch-detector.enable = true;
    podman.enable = true;
    uxplay.enable = true;
  };

  gpg.enable = true;
  keyring.enable = true;
  nur.enable = true;
  agenix.enable = true;

  impermanence.enable = true;

  hm.home.packages = with pkgs; [
    horizontallyspinningrat

    obs-studio
    neofetch
    wl-clipboard
    pavucontrol
    telegram-desktop
    lazygit
    xdg-utils

    ripgrep
  ];

  os.programs.nm-applet.enable = true;

  os.environment.systemPackages = [pkgs.wget];
}
