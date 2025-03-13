{pkgs, ...}: let
  secondarySink = "tunnel.max.local.alsa_output.usb-Logitech_PRO_X_000000000000-00.analog-stereo";
in {
  users.main = "neoney";

  bluetooth.enable = true;

  display = {
    enable = true;

    enableTearing = true;

    monitors = {
      main = {
        name = "DP-1";
        wallpaper = ../../wallpapers/blue_blobs.jpg;
        width = 2560;
        height = 1440;
        refreshRate = 144;
      };
      secondary = {
        name = "DP-3";
        wallpaper = ../../wallpapers/blue_blobs.jpg;
        width = 1920;
        height = 1080;
      };
    };

    inherit secondarySink;
    keyboards = [
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
      "logitech-k400-plus"
      "corne-keyboard"
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
    adb.enable = true;
    waydroid.enable = true;
    anyrun.enable = true;
    bottles.enable = true;
    btop.enable = true;
    # cinny.enable = true;
    discord.enable = true;
    ags.enable = true;
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
    webstorm.enable = true;
    neovim.enable = true;
    ngrok.enable = true;
    obs-studio.enable = true;
    orcaSlicer.enable = true;
    rider.enable = true;
    spotify.enable = true;
    swappy.enable = true;
    thunderbird.enable = true;
    vscode.enable = true;
    # zed.enable = true;
    zenBrowser.enable = true;
    zoxide.enable = true;
  };

  services = {
    warp.enable = true;
    kde_connect.enable = true;
    podman.enable = true;
    openrgb = {
      enable = true;
      motherboard = "amd";
    };
    kondo.enable = true;
    syncthing.enable = true;
    yubikey-touch-detector.enable = true;
    # uxplay.enable = true;
  };

  impermanence.enable = true;
  keyring.enable = true;
  nur.enable = true;
  agenix.enable = true;

  hm.home.packages = with pkgs; [
    cloudflared
    horizontallyspinningrat
    unzip

    neofetch
    wl-clipboard
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
