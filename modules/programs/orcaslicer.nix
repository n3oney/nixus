{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    orcaslicer = let
      version = "2.3.0";
    in (pkgs.appimageTools.wrapType2 {
      pname = "orca-slicer";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
        hash = "sha256-E+QL8nTwAS6DIlOfwIw2fIboPm3jrCBJaNoOMmNLMnA=";
      };

      extraPkgs = pkgs: [pkgs.webkitgtk_4_1];

      profile = ''
        export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
      '';
    });
  in {
    impermanence.userDirs = [".config/OrcaSlicer" ".local/share/orca-slicer"];

    hm = {
      home.packages = [orcaslicer];

      xdg.desktopEntries.orca-slicer = {
        name = "Orca Slicer";
        exec = "${orcaslicer}/bin/orca-slicer";
        terminal = false;
        type = "Application";
      };
    };
  });
}
