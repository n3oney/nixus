{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming = {
    steam = {
      enable = lib.mkEnableOption "gaming";
      proton-ge.enable = lib.mkEnableOption "proton-ge";
    };
    gamemode.enable = lib.mkEnableOption "gamemode" // {default = config.programs.gaming.steam.enable || config.programs.gaming.xonotic.enable || config.programs.gaming.minecraft.enable;};
    steeringWheel.enable = lib.mkEnableOption "steering wheel";
  };

  config.impermanence.userDirs = lib.mkIf config.programs.gaming.steam.enable [".local/share/steam" ".steam"];

  config.os = lib.mkMerge [
    (lib.mkIf config.programs.gaming.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [gamescope libkrb5 keyutils];
        };
      };

      programs.gamescope.enable = true;

      programs.steam.extraCompatPackages = lib.mkIf config.programs.gaming.steam.proton-ge.enable [
        pkgs.proton-ge-bin
      ];
    })

    {
      programs.gamemode.enable = config.programs.gaming.gamemode.enable;
    }

    (lib.mkIf config.programs.gaming.steeringWheel.enable {
      environment.etc."usb_modeswitch.d/046d:c261".text = ''
        # Logitech G920 Racing Wheel
        DefaultVendor=046d
        DefaultProduct=c261
        MessageEndpoint=01
        ResponseEndpoint=01
        TargetClass=0x03
        MessageContent="0f00010142"
      '';

      services.udev.extraRules = ''
        ATTR{idVendor}=="046d", ATTR{idProduct}=="c261", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -c '/etc/usb_modeswitch.d/046d:c261'"
      '';
      services.udev.packages = with pkgs; [usb-modeswitch-data];
    })
  ];
}
