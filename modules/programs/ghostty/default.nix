{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.ghostty.enable = lib.mkEnableOption "ghostty";

  config.hm = lib.mkIf config.programs.ghostty.enable {
    home.packages = [pkgs.ghostty];

    xdg.configFile."ghostty/config".text = let
      colors = config.colors.colorScheme.palette;
      format = import ./format.nix;
    in
      format {
        background = "#${colors.base00}";
        background-opacity = builtins.toString config.colors.backgroundAlpha;
        foreground = "#${colors.base05}";

        font-family = "monospace";
        font-size = "11";

        window-padding-x = "8";
        window-padding-y = "8";
        window-padding-color = "extend";

        palette = [
          "0=#090618"
          "1=#${colors.base08}"
          "2=#76946a"
          "3=#c0a36e"
          "4=#${colors.base0D}"
          "5=#${colors.base0E}"
          "6=#6a9589"
          "7=#${colors.base04}"
          "8=#${colors.base03}"
          "9=#e82424"
          "10=#${colors.base0B}"
          "11=#e6c384"
          "12=#${colors.base0C}"
          "13=#${colors.base06}"
          "14=#7aa89f"
          "15=#${colors.base05}"
        ];

        gtk-single-instance = "true";

        confirm-close-surface = "false";
        /*
        regular0 = "090618";
        regular1 = colors.base08;
        regular2 = "76946a";
        regular3 = "c0a36e";
        regular4 = colors.base0D;
        regular5 = colors.base0E;
        regular6 = "6a9589";
        regular7 = colors.base04;
        bright0 = colors.base03;
        bright1 = "e82424";
        bright2 = colors.base0B;
        bright3 = "e6c384";
        bright4 = colors.base0C;
        bright5 = colors.base06;
        bright6 = "7aa89f";
        bright7 = colors.base05;
        */
      };
  };
}
