{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.swappy.enable = lib.mkEnableOption "swappy";

  config.h.packages = lib.mkIf config.programs.swappy.enable [
    pkgs.swappy
  ];
}
