{
  pkgs,
  lib,
  # inputs,
  ...
}: {
  security.lanzaboote.enable = true;

  users.main = "neoney";

  rebuildCommand = "nh os switch $argv -- --impure";

  bluetooth.enable = true;

  display = {
    enable = true;

    monitors = [
      {
        name = "eDP-1";
        width = 2560;
        height = 1600;
        refreshRate = 165;
        scale = 1.333333;
        isMain = true;
        workspaces = [
          {
            id = 1;
            gapsIn = 0;
            gapsOut = 0;
          }
          {
            id = 2;
            default = true;
          }
          3
          4
          5
          6
          7
          8
          {
            id = 9;
            gapsIn = 0;
            gapsOut = 0;
          }
          10
        ];
        workspaceMod = "SUPER";
        workspaceKey = id: toString (lib.mod id 10);
      }
    ];

    keyboards = [
      "corne-keyboard"
    ];
    mouseSensitivity = 0.00;

    deviceOverrides = [
      {
        name = "corne-mouse";
        sensitivity = -0.7;
      }
      {
        name = "zmk-project-corne-mouse";
        sensitivity = -0.7;
      }
    ];

    screenshotKeybinds = {
      active = ", Print";
      area = "SHIFT, Print";
    };
  };

  applications.discord.defaultWorkspace = 9;

  applications.telegram = {
    autostart = true;
    binaryPath = lib.getExe pkgs.telegram-desktop;
    defaultWorkspace = 9;
    defaultColumnWidth = 0.75;
    windowClass = "org.telegram.desktop";
    blockFromScreencast = true;
  };

  programs = {
    # waydroid.enable = true;
    anyrun.enable = false;
    vicinae.enable = true;
    btop.enable = true;
    # bricscad.enable = true;
    datagrip.enable = true;
    discord = {
      enable = true;
    };
    gns3.enable = false;
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

    vivaldi.enable = true;
    # zenBrowser.enable = true;
    zed.enable = true;
    zoxide.enable = true;
  };

  wayscriber.enable = true;

  services = {
    fcitx5.enable = true;
    syncthing.enable = true;
    mcp.enable = true;
    ollama.enable = true;
    tlp.enable = true;
    yubikey-touch-detector.enable = true;
    podman.enable = true;
    # uxplay.enable = true;
    # warp.enable = true;
    kondo.enable = true;
  };

  biometricAuth.howdy.enable = true;

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
