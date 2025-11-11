{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    # orcaslicer = pkgs.orca-slicer-nightly;
    orcaslicer = pkgs.orca-slicer.overrideAttrs (old: {
      pname = "orca-slicer-nightly";
      version = "unstable-${inputs.orcaslicer.lastModifiedDate}";
      src = inputs.orcaslicer;
      cmakeFlags =
        old.cmakeFlags
        ++ [
          (lib.cmakeBool "LIBNOISE_LIBRARY_RELEASE" true)
        ];
    });
  in {
    impermanence.userDirs = [".config/OrcaSlicer" ".local/share/orca-slicer"];

    hm = {
      home.packages = [orcaslicer];
    };
  });
}
