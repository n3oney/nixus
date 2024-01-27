{
  inputs,
  lib,
  config,
  ...
}: {
  options.programs.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkMerge [
    (lib.mkIf config.programs.btop.enable {
      hm = {
        xdg.configFile."btop/themes/catppuccin_macchiato.theme".source = "${inputs.btop}/themes/catppuccin_macchiato.theme";

        programs.btop = {
          enable = true;
          settings = {
            color_theme = "catppuccin_macchiato";
          };
        };
      };
    })
  ];
}
