{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.spotify.enable = lib.mkEnableOption "Spotify";

  config.hm = lib.mkIf config.programs.spotify.enable {
    home.packages = [pkgs.spotify];
  };
}
