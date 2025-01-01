{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.zenBrowser.enable = lib.mkEnableOption "Zen Browser";

  config.hm = lib.mkIf config.programs.zenBrowser.enable (let
    zenBrowser =
      /*
                        pkgs.appimageTools.wrapType2 rec {
        pname = "zen-browser";
        version = "1.0.2-b.5";

        src = pkgs.fetchurl {
          url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-${
            {
              x86_64-linux = "x86_64";
              aarch64-linux = "aarch64";
            }
            ."${pkgs.system}"
          }.AppImage";
          hash =
            {
              x86_64-linux = "sha256-faJzPHtjE3Q+9WpPm1Lip4f7RJQrhWdTU+MFaCXy2Xg=";
              aarch64-linux = "sha256-mKr+6CGG/KgHBylOxZBEmRdJv+rEfICtf1i164dKJIw=";
            }
            ."${pkgs.system}";
        };

        extraPkgs = pkgs: [pkgs.ffmpeg];

        profile = ''
          export GST_PLUGIN_SYSTEM_PATH_1_0=/usr/lib/gstreamer-1.0
        '';
      };
      */
      inputs.zen-browser-flake.packages.${pkgs.system}.zen-browser;
  in {
    /*
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
    */

    xdg.mimeApps.enable = true;
    home.packages = [zenBrowser];
    xdg.mimeApps.defaultApplications = {
      "x-scheme-handler/https" = ["zen.desktop"];
      "x-scheme-handler/http" = ["zen.desktop"];
      "text/html" = ["zen.desktop"];
      "text/xml" = ["zen.desktop"];
      "application/xhtml+xml" = ["zen.desktop"];
      "application/vnd.mozilla.xul+xml" = ["zen.desktop"];
    };
  });
}
