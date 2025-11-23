{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.zenBrowser.enable = lib.mkEnableOption "Zen Browser";

  config = lib.mkIf config.programs.zenBrowser.enable (let
    zenBrowser = inputs.zen-browser-flake.packages.${pkgs.system}.zen-browser.overrideAttrs (old: {
      # buildCommand =
      #   old.buildCommand
      #   + ''
      #     mkdir -p $out/gmp-widevinecdm/system-installed
      #     ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_arm64/libwidevinecdm.so" $out/gmp-widevinecdm/system-installed/libwidevinecdm.so
      #     ln -s "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json" $out/gmp-widevinecdm/system-installed/manifest.json
      #     wrapProgram "$oldExe" \
      #             --set MOZ_GMP_PATH "$out/gmp-widevinecdm/system-installed"
      #   '';
    });
  in {
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
