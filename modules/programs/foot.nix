{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.foot.enable = lib.mkEnableOption "foot";

  config.hm = lib.mkIf config.programs.foot.enable {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "monospace:size=11";
          pad = "8x8 center";
        };

        colors = let
          colors = config.colors.colorScheme.colors;
        in {
          alpha = config.colors.backgroundAlpha;
          foreground = colors.base05;
          background = colors.base00;

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
        };
      };
    };

    xdg.desktopEntries.Helix = lib.mkForce {
      type = "Application";
      name = "Helix";
      mimeType = ["text/plain"];
      exec = "${pkgs.writeShellScript "foot-helix.sh" ''
        filename="$(readlink -f "$1")"
        dirname="$(dirname "$filename")"

        ${lib.getExe pkgs.foot} -D "$dirname" ${lib.getExe pkgs.fish} -C "${lib.getExe pkgs.direnv} exec . ${lib.getExe pkgs.helix} '$filename'"
      ''} %f";
    };
  };
}
