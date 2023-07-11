{pkgs, ...}: let
  secondarySink = "raop_sink.raspberrypi.local.192.168.1.4.5000";
in {
  users.main = "neoney";

  display = {
    enable = true;

    monitors = {
      main = {
        name = "DP-1";
        wallpaper = ../../wallpapers/cherry/primary.png;
        width = 2560;
        height = 1440;
      };
      secondary = {
        name = "DP-3";
        wallpaper = ../../wallpapers/cherry/secondary.png;
        width = 1920;
        height = 1080;
      };
    };

    inherit secondarySink;
    keyboards = [
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
    ];
    mouseSensitivity = -0.76;

    screenshotKeybinds = {
      active = ", Print";
      area = "SHIFT, Print";
      all = "ALT, Print";
    };
  };

  programs = {
    anyrun.enable = true;
    btop.enable = true;
    discord.enable = true;
    eww = {
      enable = true;
      micName = "Blue Snowball Mono";
    };
    firefox.enable = true;
    foot.enable = true;
    gaming = {
      steam = {
        enable = true;
        proton-ge.enable = true;
      };
      steeringWheel.enable = true;
      xonotic.enable = true;
    };
    jellyfinPlayer.enable = true;
    neovim.enable = true;
    swappy.enable = true;
    thunderbird.enable = true;
    youtube-tv = {
      enable = true;
      audioSink = secondarySink;
    };
  };

  services = {
    kde_connect.enable = true;
    ha-poweroff.enable = true;
    podman.enable = true;
    openrgb = {
      enable = true;
      motherboard = "amd";
    };
    yubikey-touch-detector.enable = true;
  };

  impermanence.enable = true;
  gpg.enable = true;
  keyring.enable = true;
  nur.enable = true;
  agenix.enable = true;

  hm.home.packages = with pkgs; [
    horizontallyspinningrat

    obs-studio
    neofetch
    wl-clipboard
    cider
    pavucontrol
    telegram-desktop
    lazygit
    xdg-utils

    ripgrep
  ];

  os.environment.systemPackages = [pkgs.wget];
  os.security.rtkit.enable = true;
}
