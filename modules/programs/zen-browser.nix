{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.zenBrowser.enable = lib.mkEnableOption "Zen Browser";

  config.hm = lib.mkIf config.programs.zenBrowser.enable (let
    zenBrowser = pkgs.appimageTools.wrapType2 rec {
      pname = "zen-browser";
      version = "1.0.1-a.10";

      src = pkgs.fetchurl {
        url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-specific.AppImage";
        hash = "sha256-pZfYZ0cfQUV8mcLKJKnVaRhyCPKVs/y84+tIWUdQnww=";
      };

      extraPkgs = pkgs: [pkgs.ffmpeg];

      profile = ''
        export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
      '';
    };
  in {
    xdg.desktopEntries.zen = {
      exec = "${zenBrowser}/bin/zen-browser %U";
      name = "Zen";
      categories = ["Network" "WebBrowser"];
      genericName = "Web Browser";
      mimeType = ["text/html" "text/xml" "application/xhtml+xml" "application/vnd.mozilla.xul+xml" "x-scheme-handler/http" "x-scheme-handler/https"];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/https" = ["zen.desktop"];
      };
    };

    home.packages = [zenBrowser];
  });
}
