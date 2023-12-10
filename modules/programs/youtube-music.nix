{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.youtube-music.enable = lib.mkEnableOption "YouTube Music";

  config.hm = lib.mkIf config.programs.youtube-music.enable {
    home.packages = [pkgs.ytmdesktop];
  };
}
