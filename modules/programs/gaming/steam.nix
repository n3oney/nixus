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
    gamemode.enable = lib.mkEnableOption "gamemode" // {default = config.programs.gaming.steam.enable || config.programs.gaming.xonotic.enable || config.programs.gaming.minecraft.enable;};
  };

  config.impermanence.userDirs = lib.mkIf config.programs.gaming.steam.enable [
    ".local/share/steam"
    ".local/share/Steam"
    ".steam"
  ];

  config.os = lib.mkMerge [
    (lib.mkIf config.programs.gaming.steam.enable {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        package = pkgs.steam.override {
          extraPkgs = pkgs: with pkgs; [gamescope libkrb5 keyutils nspr nss_latest];
        };
      };

      programs.gamescope.enable = true;

      programs.steam.extraCompatPackages = lib.mkIf config.programs.gaming.steam.proton-ge.enable [
        pkgs.proton-ge-bin
        ((pkgs.proton-ge-bin.override {steamDisplayName = "GE-Proton8-27";}).overrideAttrs (old: rec {
          version = "GE-Proton8-27";
          src = pkgs.fetchzip {
            url = "https://github.com/GloriousEggroll/proton-ge-custom/releases/download/${version}/${version}.tar.gz";
            hash = "sha256-YeibTA2z69bNE3V/sgFHOHaxl0Uf77unQQc7x2w/1AI=";
          };
        }))
      ];
      programs.steam.protontricks.enable = true;
    })

    {
      programs.gamemode.enable = config.programs.gaming.gamemode.enable;
    }
  ];
}
