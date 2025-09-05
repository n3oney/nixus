{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.openrgb;
  inherit (lib) mkEnableOption mkIf;
in {
  options.services.openrgb = {
    enable = mkEnableOption "OpenRGB";
  };

  config.os.services.hardware.openrgb = mkIf cfg.enable {
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };
}
