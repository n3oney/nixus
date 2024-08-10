{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  options.programs.curaSlicer.enable = lib.mkEnableOption "Cura";

  config.hm = lib.mkIf config.programs.curaSlicer.enable {
    home.packages = [inputs.nixpkgs-2405.legacyPackages.${pkgs.system}.cura];
  };
}
