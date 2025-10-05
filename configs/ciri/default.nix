{
  pkgs,
  # inputs,
  ...
}: {
  users.main = "neoney";

  rebuildCommand = "nh os switch $argv -- --impure";

  bluetooth.enable = true;

  display = {
    enable = true;

    monitors = {
      main = {
        name = "eDP-1";
        wallpaper = ../../wallpapers/blue_blobs.jpg;
        width = 2560;
        height = 1600;
        refreshRate = 60;
        scale = 1.333333;
      };
    };

    keyboards = [
      "apple-internal-keyboard-/-trackpad"
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
      "corne-keyboard"
    ];
    mouseSensitivity = 0.00;

    screenshotKeybinds = {
      active = ", XF86LaunchA";
      area = "SHIFT, XF86LaunchA";
      # all = ", XF86LaunchB";
    };
  };

  programs = {
    # waydroid.enable = true;
    anyrun.enable = true;
    btop.enable = true;
    cinny.enable = true;
    discord.enable = true;
    ags.enable = true;
    # firefox.enable = true;
    foot.enable = true;
    neovim.enable = true;
    obs-studio.enable = true;
    opencode.enable = true;
    rider.enable = true;
    swappy.enable = true;
    orcaSlicer.enable = true;
    thunderbird.enable = true;
    gaming = {
      # no steam build for aarch64 :(
      # steam.enable = true;
      minecraft.enable = true;
      gamemode.enable = true;
    };

    ngrok.enable = true;

    vscode.enable = true;

    # webstorm.enable = true;

    zenBrowser.enable = true;
    zed.enable = true;
    zoxide.enable = true;
  };

  services = {
    mcp.enable = true;
    tlp.enable = true;
    yubikey-touch-detector.enable = true;
    podman.enable = true;
    # uxplay.enable = true;
    # warp.enable = true;
    kondo.enable = true;
  };

  keyring.enable = true;
  nur.enable = true;
  agenix.enable = true;

  impermanence.enable = true;

  hm.home.packages = with pkgs; [
    horizontallyspinningrat

    neofetch
    wl-clipboard
    pavucontrol
    telegram-desktop
    xdg-utils

    ripgrep
  ];

  os.programs.nm-applet.enable = true;
  os.programs.nix-ld.enable = true;

  os.environment.systemPackages = [pkgs.wget];
}
