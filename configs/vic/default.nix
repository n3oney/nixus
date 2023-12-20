{pkgs, ...}: {
  users.main = "neoney";

  rebuildCommand = "nh os switch -- --impure";

  display = {
    enable = true;

    monitors = {
      main = {
        name = "eDP-1";
        wallpaper = ../../wallpapers/cherry/laptop.png;
        width = 2560;
        height = 1600;
        refreshRate = 60;
        scale = 1.5;
      };
    };

    keyboards = [
      "apple-internal-keyboard-/-trackpad-1"
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
    ];
    mouseSensitivity = 0.00;

    screenshotKeybinds = {
      active = ", XF86LaunchA";
      area = "SHIFT, XF86LaunchA";
      # all = ", XF86LaunchB";
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
    /*
    gaming = {
      steam = {
      enable = true;
      proton-ge.enable = true;
      };
    };
    */

    # Won't be watching stuff until speakers work...
    # jellyfinPlayer.enable = true;
    # youtube-music.enable = true;
  };

  services = {
    wg.enable = true;
    yubikey-touch-detector.enable = true;
    podman.enable = true;
    # uxplay.enable = true;
    kondo.enable = true;
  };

  gpg.enable = true;
  keyring.enable = true;
  nur.enable = true;
  agenix.enable = true;

  # impermanence.enable = true;

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
