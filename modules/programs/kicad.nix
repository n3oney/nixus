{
  lib,
  pkgs,
  config,
  ...
}: {
  options.programs.kicad.enable = lib.mkEnableOption "KiCad";

  config = lib.mkIf config.programs.kicad.enable {
    h.packages = [pkgs.kicad];

    impermanence.userDirs = [".config/kicad" ".local/share/kicad"];
  };
}
