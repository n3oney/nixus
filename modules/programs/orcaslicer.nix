{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config.hm = lib.mkIf config.programs.curaSlicer.enable {
    home.packages = [pkgs.orca-slicer];
  };
}
