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
        xdg.configFile."btop/themes/rose-pine.theme".source = "${inputs.btop-rose-pine}/rose-pine.theme";

        programs.btop = {
          enable = true;
          settings = {
            color_theme = "rose-pine";
          };
        };
      };
    })
  ];
}
