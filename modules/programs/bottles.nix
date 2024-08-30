{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.bottles.enable = lib.mkEnableOption "Bottles";

  config.hm.home.packages = lib.mkIf config.programs.bottles.enable [pkgs.bottles];
}
