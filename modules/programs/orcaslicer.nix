{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    orcaslicer = let
      shortVersion = "V2.3.1-beta";
      version = "v2.3.1-beta";
    in (pkgs.appimageTools.wrapType2 {
      pname = "orca-slicer";
      inherit version;

      src = pkgs.fetchurl {
        url = "https://github.com/SoftFever/OrcaSlicer/releases/download/${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_${shortVersion}.AppImage";
        sha256 = "sha256-a9IBGPItM+SvWEHtH+EhXR9VurL0QoCHtW5zRzPn3Kg=";
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
