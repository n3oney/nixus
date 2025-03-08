{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.bottles.enable = lib.mkEnableOption "Bottles";

  config = lib.mkIf config.programs.bottles.enable {
    hm.home.packages = [pkgs.bottles];

    impermanence.userDirs = [".local/share/bottles"];
  };
}
