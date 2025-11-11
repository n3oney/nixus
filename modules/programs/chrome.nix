{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.chrome.enable = lib.mkEnableOption "Chrome";

  config = lib.mkIf config.programs.chrome.enable {
    impermanence.userDirs = [".config/chromium"];

    hm.programs.chromium = {
      package = pkgs.chromium;
      enable = true;
    };
  };
}
