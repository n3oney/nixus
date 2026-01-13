{
  pkgs,
  lib,
  config,
  ...
}: let
  bricscad = pkgs.stdenv.mkDerivation rec {
    pname = "bricscad";
    version = "26.1.07";

    src = pkgs.requireFile {
      name = "BricsCAD-V${version}-1-en_US-amd64.tar.gz";
      sha256 = "038mkjw2xyipcp6hk5nf3rqxszkhr5p6c8177mqgnb5ljwsxymhj";
      url = "https://www.bricsys.com/en-us/bricscad/download";
    };

    nativeBuildInputs = [pkgs.autoPatchelfHook pkgs.makeWrapper pkgs.qt6.wrapQtAppsHook];

    autoPatchelfIgnoreMissingDeps = true;

    buildInputs = with pkgs; [
      gtk3
      glib
      gdk-pixbuf
      pango
      cairo
      libGL
      libGLU
      xorg.libX11
      xorg.libXext
      xorg.libXrender
      xorg.libXi
      xorg.libXcursor
      xorg.libXrandr
      xorg.libXfixes
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXtst
      xorg.libxcb
      fontconfig
      freetype
      zlib
      libsecret
      nss
      nspr
      alsa-lib
      cups
      dbus
      expat
      libdrm
      mesa
      libxkbcommon
      libxkbcommon.dev
      libxml2_13
      qt6.qtbase
      qt6.qtwayland
      qt6.qtdeclarative
      qt6.qtsvg
      qt6.qt5compat
      wxGTK31
      xercesc
      webkitgtk_6_0
    ];

    sourceRoot = ".";

    runtimeLibs = with pkgs; [
      libxml2_13
    ];

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,lib,opt/bricscad}

      # Copy everything to opt
      cp -r * $out/opt/bricscad/

      # Copy bundled .so and .tx files to lib so autoPatchelf can find them
      cp $out/opt/bricscad/*.so* $out/lib/ 2>/dev/null || true
      cp $out/opt/bricscad/*.tx $out/lib/ 2>/dev/null || true

      # Create wrapper script with LD_LIBRARY_PATH for .tx modules
      makeWrapper $out/opt/bricscad/bricscad $out/bin/bricscad \
        --prefix LD_LIBRARY_PATH : "$out/opt/bricscad:$out/lib"

      runHook postInstall
    '';

    meta = with lib; {
      description = "BricsCAD - Professional CAD software";
      homepage = "https://www.bricsys.com";
      license = licenses.unfree;
      platforms = ["x86_64-linux"];
    };
  };
in {
  options.programs.bricscad.enable = lib.mkEnableOption "BricsCAD";

  config = lib.mkIf config.programs.bricscad.enable {
    hm.home.packages = [bricscad];

    # BricsCAD needs this directory for licensing
    os.systemd.tmpfiles.rules = [
      "d /var/tmp/bricsys 0777 root root -"
    ];
  };
}
