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
      inputs.zen-browser-flake.packages.${pkgs.system}.zen-browser;
  in {
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
