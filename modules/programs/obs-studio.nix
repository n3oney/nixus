{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.obs-studio.enable = lib.mkEnableOption "OBS Studio";

  config = lib.mkIf config.programs.obs-studio.enable {
    impermanence.userDirs = [".config/obs-studio"];

    hm.home.packages = [
      (pkgs.wrapOBS {
        plugins = [pkgs.obs-studio-plugins.droidcam-obs];
      })
    ];
  };
}
