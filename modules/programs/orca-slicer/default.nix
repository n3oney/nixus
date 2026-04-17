{
  pkgs,
  lib,
  config,
  sources,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    appimageContents = pkgs.appimageTools.extract sources.orca-slicer;

    orcaslicer = pkgs.appimageTools.wrapType2 (sources.orca-slicer
      // {
        extraPkgs = pkgs: [pkgs.webkitgtk_4_1 pkgs.libsoup_3 pkgs.glib-networking];

        profile = "export GIO_EXTRA_MODULES=${pkgs.glib-networking}/lib/gio/modules\${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}";

        extraInstallCommands = ''
          install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/192x192/apps/OrcaSlicer.png \
            $out/share/icons/hicolor/192x192/apps/OrcaSlicer.png

          install -m 444 -D ${appimageContents}/usr/share/applications/com.orcaslicer.OrcaSlicer.desktop \
            $out/share/applications/com.orcaslicer.OrcaSlicer.desktop

          substituteInPlace $out/share/applications/com.orcaslicer.OrcaSlicer.desktop \
            --replace-fail 'Exec=AppRun %F' 'Exec=orca-slicer %U' \
            --replace-fail 'MimeType=' 'MimeType=x-scheme-handler/orcaslicer;'
        '';

        meta = {
          description = "G-code generator for 3D printers (Bambu, Prusa, Voron, VzBot, RatRig, Creality, etc.)";
          homepage = "https://github.com/OrcaSlicer/OrcaSlicer";
          license = lib.licenses.agpl3Only;
          mainProgram = "orca-slicer";
          platforms = lib.platforms.linux;
        };
      });
  in {
    impermanence.userDirs = [".config/OrcaSlicer" ".local/share/orca-slicer"];

    h.packages = [orcaslicer];
  });
}
