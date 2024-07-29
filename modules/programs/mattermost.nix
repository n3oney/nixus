{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.mattermost.enable = lib.mkEnableOption "Mattermost";

  config.hm = lib.mkIf config.programs.mattermost.enable {
    home.packages = [pkgs.mattermost-desktop];
  };
}
