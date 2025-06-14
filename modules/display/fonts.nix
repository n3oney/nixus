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
        nerd-fonts.monaspace
        nerd-fonts.jetbrains-mono
        roboto
        roboto-serif
        inter
        font-awesome
        font-awesome_5
        font-awesome_4
        joypixels
        noto-fonts
        noto-fonts-cjk-sans
        nerd-fonts.fira-code
      ];

      enableDefaultPackages = false;

      fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = ["Inter"];
          serif = ["Roboto Serif"];
          monospace = ["FiraCode Nerd Font" "MonaspiceNe Nerd Font" "TwilioSansM Nerd Font" "Cozette"];
          emoji = ["JoyPixels"];
        };
      };
    };
  };
}
