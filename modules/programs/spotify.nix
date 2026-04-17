{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.spotify.enable = lib.mkEnableOption "Spotify";

  config = lib.mkIf config.programs.spotify.enable {
    h.packages = [pkgs.spotify];

    impermanence.userDirs = [".config/spotify"];
  };
}
