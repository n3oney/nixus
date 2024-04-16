{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.obsidian.enable = lib.mkEnableOption "Obsidian";

  config.hm = lib.mkIf config.programs.obsidian.enable {
    home.packages = [pkgs.obsidian];
  };
}
