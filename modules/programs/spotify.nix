{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.spotify.enable = lib.mkEnableOption "Spotify";

  config = lib.mkIf config.programs.spotify.enable {
    hm.home.packages = [pkgs.spotify];

    impermanence.userDirs = [".config/spotify"];
  };
}
