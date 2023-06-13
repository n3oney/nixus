{
  inputs.btop = {
    url = "github:catppuccin/btop";
    flake = false;
  };

  home = {inputs, ...}: {
    xdg.configFile."btop/themes/catppuccin_macchiato.theme".source = "${inputs.btop}/themes/catppuccin_macchiato.theme";

    programs.btop = {
      enable = true;
      settings = {
        color_theme = "catppuccin_macchiato";
      };
    };
  };
}
