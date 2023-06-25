{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.gaming = {
    steam = {
      enable = lib.mkEnableOption "gaming";
      proton-ge.enable = lib.mkEnableOption "proton-ge";
    };
    gamemode.enable = lib.mkEnableOption "gamemode" // {default = config.programs.gaming.steam.enable || config.programs.gaming.xonotic.enable;};
    steeringWheel.enable = lib.mkEnableOption "steering wheel";
  };

  config.inputs.nix-gaming.url = "github:fufexan/nix-gaming";

  config.os = lib.mkMerge [
    (lib.mkIf config.programs.gaming.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
      };
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

  config.hm = lib.mkIf (config.programs.gaming.steam.enable && config.programs.gaming.steam.proton-ge.enable) {
    home.sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "${inputs.nix-gaming.packages.${pkgs.system}.proton-ge}";
    };
  };
}
