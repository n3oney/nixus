{
  lib,
  config,
  pkgs,
  sources,
  ...
}: let
  helium-unwrapped = pkgs.appimageTools.wrapType2 {
    inherit (sources.helium) pname version src;
  };
  helium-appimage-contents = pkgs.appimageTools.extract {
    inherit (sources.helium) pname version src;
  };
  helium = pkgs.stdenv.mkDerivation {
    inherit (sources.helium) pname version;
    src = helium-unwrapped;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/bin $out/share/applications $out/share/icons
      cp -r ${helium-unwrapped}/bin/* $out/bin/
      cp ${helium-appimage-contents}/helium.desktop $out/share/applications/ || true
      cp -r ${helium-appimage-contents}/usr/share/icons/* $out/share/icons/ || true
      substituteInPlace $out/share/applications/helium.desktop \
        --replace-quiet "Exec=AppRun" "Exec=helium"
    '';
    meta.mainProgram = "helium";
  };
in {
  options.programs.helium.enable = lib.mkEnableOption "Helium";

  config = lib.mkIf config.programs.helium.enable {
    applications.helium = {
      autostart = true;
      binaryPath = lib.getExe helium;
      defaultWorkspace = 2;
      windowClass = "helium";
    };

    impermanence.userDirs = [
      ".config/net.imput.helium"
      ".cache/net.imput.helium"
    ];

    hm = {
      home.packages = [helium];

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "helium.desktop";
          "x-scheme-handler/http" = "helium.desktop";
          "x-scheme-handler/https" = "helium.desktop";
          "x-scheme-handler/about" = "helium.desktop";
          "x-scheme-handler/unknown" = "helium.desktop";
        };
      };
    };
  };
}
