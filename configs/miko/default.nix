{pkgs, ...}: let
  secondarySink = "tunnel.max.local.alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo";
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
      monitor = "CTRL, Print";
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
      minecraft.enable = true;
      steeringWheel.enable = true;
      xonotic.enable = true;
    };
    jellyfinPlayer.enable = true;
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
    uxplay.enable = true;
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
    mxw
  ];

  os.programs.nix-ld.enable = true;

  os.environment.systemPackages = [pkgs.wget];
  os.security.rtkit.enable = true;
}
