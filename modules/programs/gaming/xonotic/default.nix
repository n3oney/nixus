{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.xonotic.enable = lib.mkEnableOption "xonotic";

  config = lib.mkIf config.programs.gaming.xonotic.enable {
    h.packages = [pkgs.xonotic];
    impermanence.userDirs = [".xonotic"];
  };
}
