{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.chrome.enable = lib.mkEnableOption "Chrome";

  config = lib.mkIf config.programs.chrome.enable {
    impermanence.userDirs = [".config/google-chrome"];

    hm.programs.chromium = {
      package = pkgs.google-chrome;
      enable = true;
    };
  };
}
