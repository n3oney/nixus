{
  inputs = {
    nix-colors.url = "github:Misterio77/nix-colors";
  };

  add = {nix-colors, ...}: {
    homeModules = [nix-colors.homeManagerModules.default];
  };

  home = {inputs, ...}: {
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-macchiato // {colors = inputs.nix-colors.colorSchemes.catppuccin-macchiato.colors // {accent = "f5bde6";};};

    # colorScheme = nc-lib.colorSchemeFromPicture {
    #   path = ../wallpapers/cherry/cherry.png;
    #   kind = "dark";
    # };

    # colorScheme = {
    #   name = "Slick";
    #   slug = "slick";
    #   author = "neoney (https://github.com/n3oney)";
    #   colors = {
    #     base00 = "11111b"; # background
    #     base01 = "1e1e2e";
    #     base02 = "39394d";
    #     base03 = "39394d";
    #     base04 = "6095c5";
    #     base05 = "cdd6f4"; # foreground
    #     base06 = "6ca399";
    #     base07 = "7a6f67";
    #     base08 = "e65050";
    #     base09 = "e65050";
    #     base0A = "d7b07c";
    #     base0B = "91d186";
    #     base0C = "98cbfe";
    #     base0D = "98cbfe";
    #     base0E = "d681b5";
    #     base0F = "faf3ee";
    #   };
    # };
  };
}
