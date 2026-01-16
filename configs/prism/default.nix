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
        width = 2560;
        height = 1600;
        refreshRate = 165;
        scale = 1.333333;
      };
    };

    keyboards = [
      "logitech-g915-tkl-lightspeed-wireless-rgb-mechanical-gaming-keyboard"
      "logitech-usb-receiver-keyboard"
      "corne-keyboard"
    ];
    mouseSensitivity = 0.00;

    screenshotKeybinds = {
      active = ", Print";
      area = "SHIFT, Print";
    };
  };

  applications.discord.defaultWorkspace = 9;

  programs = {
    # waydroid.enable = true;
    anyrun.enable = true;
    btop.enable = true;
    # bricscad.enable = true;
    chrome.enable = true;
    datagrip.enable = true;
    discord = {
      enable = true;
      useDissent = true;
    };
    # ags.enable = true;
    quickshell.enable = true;
    # firefox.enable = true;
    foot.enable = true;
    kicad.enable = true;
    neovim.enable = true;
    obs-studio.enable = true;
    opencode.enable = true;
    platformio.enable = true;
    rider.enable = true;
    swappy.enable = true;
    orcaSlicer.enable = true;
    thunderbird.enable = true;
    gaming = {
      steam.enable = true;
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

  wayscriber.enable = true;

  services = {
    syncthing.enable = true;
    mcp.enable = true;
    tlp.enable = true;
    yubikey-touch-detector.enable = true;
    podman.enable = true;
    # uxplay.enable = true;
    # warp.enable = true;
    kondo.enable = true;
  };

  biometricAuth = {
    howdy.enable = true;
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

    unzip
  ];

  os.programs.nm-applet.enable = true;
  os.programs.nix-ld.enable = true;

  os.environment.systemPackages = [pkgs.wget];
}
