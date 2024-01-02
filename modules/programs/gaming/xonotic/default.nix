{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.xonotic.enable = lib.mkEnableOption "xonotic";

  config.hm = lib.mkIf config.programs.gaming.xonotic.enable {
    home.packages = [pkgs.xonotic];
  };
}
