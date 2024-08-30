{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config.hm = lib.mkIf config.programs.orcaSlicer.enable (let
    orcaslicer = let
      version = "2.1.1";
    in (pkgs.appimageTools.wrapType2 {
      pname = "orca-slicer";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_V${version}.AppImage";
        hash = "sha256-kvM1rBGEJhjRqQt3a8+I0o4ahB1Uc9qB+4PzhYoNQdM=";
      };

      extraPkgs = pkgs: [pkgs.webkitgtk];

      profile = ''
        export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
      '';
    });
  in {
    home.packages = [orcaslicer];
  });
}
