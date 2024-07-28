{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.slack.enable = lib.mkEnableOption "slack";

  config.hm = lib.mkIf config.programs.slack.enable {
    home.packages = [pkgs.slack];
  };
}
