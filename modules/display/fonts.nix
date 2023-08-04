{
  config,
  lib,
  pkgs,
  ...
}: {
  config.os = lib.mkIf config.display.enable {
    nixpkgs.config.joypixels.acceptLicense = true;

    fonts = {
      packages = with pkgs; [
        cozette
        (nerdfonts.override {fonts = ["JetBrainsMono"];})
        roboto
        roboto-serif
        gg-sans
        font-awesome
        font-awesome_5
        font-awesome_4
        joypixels
        noto-fonts
        noto-fonts-cjk
      ];

      enableDefaultPackages = false;

      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = ["gg sans"];
          serif = ["Roboto Serif"];
          monospace = ["JetBrains Mono Nerd Font"];
          emoji = ["JoyPixels"];
        };
      };
    };
  };
}
