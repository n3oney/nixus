{
  config,
  lib,
  pkgs,
  ...
}: {
  config.os = lib.mkIf config.display.enable {
    nixpkgs.config.joypixels.acceptLicense = true;

    fonts = {
      fonts = with pkgs; [
        cozette
        (nerdfonts.override {fonts = ["FiraCode"];})
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

      enableDefaultFonts = false;

      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = ["gg sans"];
          serif = ["Roboto Serif"];
          monospace = ["Cozette"];
          emoji = ["JoyPixels"];
        };
      };
    };
  };
}
