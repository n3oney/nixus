{
  home = _: {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=8";
          pad = "8x8 center";
        };

        colors = {
          alpha = 0.7;
          background = "1f1f28";
          foreground = "dcd7ba";

          ## Normal/regular colors (color palette 0-7)
          regular0 = "090618"; # black
          regular1 = "c34043"; # red
          regular2 = "76946a"; # green
          regular3 = "c0a36e"; # yellow
          regular4 = "7e9cd8"; # blue
          regular5 = "957fb8"; # magenta
          regular6 = "6a9589"; # cyan
          regular7 = "dcd7ba"; # white

          ## Bright colors (color palette 8-15)
          bright0 = "727169"; # bright black
          bright1 = "e82424"; # bright red
          bright2 = "98bb6c"; # bright green
          bright3 = "e6c384"; # bright yellow
          bright4 = "7fb4ca"; # bright blue
          bright5 = "938aa9"; # bright magenta
          bright6 = "7aa89f"; # bright cyan
          bright7 = "c8c093"; # bright white
        };
      };
    };
  };
}
