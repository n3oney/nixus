{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.obs-studio.enable = lib.mkEnableOption "OBS Studio";

  config = lib.mkIf config.programs.obs-studio.enable {
    impermanence.userDirs = [".config/obs-studio"];

    h.packages = [
      (pkgs.wrapOBS {
        plugins = [];
      })
    ];
  };
}
