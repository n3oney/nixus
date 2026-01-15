{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.zenBrowser.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf config.programs.zenBrowser.enable (let
    zenBrowser = inputs.zen-browser-flake.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser;
  in {
    applications.zen = {
      autostart = true;
      binaryPath = lib.getExe zenBrowser;
      defaultWorkspace = 2;
      windowClass = "zen";
      hyprlandWindowRules = ["suppress_event maximize"];
    };

    impermanence.userDirs = [".zen"];

    hm = {
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
    };
  });
}
