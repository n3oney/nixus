{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.zenBrowser.enable = lib.mkEnableOption "Zen Browser";

  config.hm = lib.mkIf config.programs.zenBrowser.enable {
    home.packages = [inputs.zen-browser.packages."${pkgs.system}".default];
  };
}
