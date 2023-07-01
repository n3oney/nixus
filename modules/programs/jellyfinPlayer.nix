{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.jellyfinPlayer.enable = lib.mkEnableOption "Jellyfin Media Player";

  config.hm = lib.mkIf config.programs.jellyfinPlayer.enable {
    home.packages = [pkgs.jellyfin-media-player];
  };
}
