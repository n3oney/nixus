{
  home = {config, ...}: {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=8";
          pad = "8x8 center";
        };

        colors = let
          colors = config.colorScheme.colors;
        in {
          alpha = 0.7;
          foreground = colors.base05;
          background = colors.base00;

          regular0 = "090618";
          regular1 = config.colorScheme.colors.base08;
          regular2 = "76946a";
          regular3 = "c0a36e";
          regular4 = config.colorScheme.colors.base0D;
          regular5 = config.colorScheme.colors.base0E;
          regular6 = "6a9589";
          regular7 = config.colorScheme.colors.base04;
          bright0 = config.colorScheme.colors.base03;
          bright1 = "e82424";
          bright2 = config.colorScheme.colors.base0B;
          bright3 = "e6c384";
          bright4 = config.colorScheme.colors.base0C;
          bright5 = config.colorScheme.colors.base06;
          bright6 = "7aa89f";
          bright7 = config.colorScheme.colors.base05;
        };
      };
    };
  };
}
