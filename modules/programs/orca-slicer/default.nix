{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    orcaslicer = pkgs.orca-slicer-nightly;
    # orcaslicer = pkgs.orca-slicer;
  in {
    impermanence.userDirs = [".config/OrcaSlicer" ".local/share/orca-slicer"];

    hm = {
      home.packages = [orcaslicer];
    };
  });
}
