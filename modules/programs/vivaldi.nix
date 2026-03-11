{
  lib,
  config,
  hmConfig,
  ...
}: {
  options.programs.vivaldi.enable = lib.mkEnableOption "Vivaldi";

  config = lib.mkIf config.programs.vivaldi.enable {
    applications.vivaldi = {
      autostart = true;
      binaryPath = lib.getExe hmConfig.programs.vivaldi.finalPackage;
      defaultWorkspace = 2;
      windowClass = "vivaldi-stable";
    };

    impermanence.userDirs = [
      ".config/vivaldi"
      ".cache/vivaldi"
      ".local/lib/vivaldi"
    ];

    hm = {
      programs.vivaldi = {
        enable = true;
        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        ];
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ozone-platform=wayland"
        ];
      };

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "vivaldi-stable.desktop";
          "x-scheme-handler/http" = "vivaldi-stable.desktop";
          "x-scheme-handler/https" = "vivaldi-stable.desktop";
          "x-scheme-handler/about" = "vivaldi-stable.desktop";
          "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
        };
      };
    };
  };
}
