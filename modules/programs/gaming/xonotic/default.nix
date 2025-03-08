{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.xonotic.enable = lib.mkEnableOption "xonotic";

  config = lib.mkIf config.programs.gaming.xonotic.enable {
    hm.home.packages = [pkgs.xonotic];
    impermanence.userDirs = [".xonotic"];
  };
}
