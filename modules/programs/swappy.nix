{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.swappy.enable = lib.mkEnableOption "swappy";

  config.hm.home.packages = lib.mkIf config.programs.swappy.enable [
    pkgs.swappy
  ];
}
