{
  lib,
  config,
  pkgs,
  ...
}: let
  cfg = config.services.openrgb;
  inherit (lib) mkEnableOption mkIf mkOption types;
in {
  options.services.openrgb = {
    enable = mkEnableOption "OpenRGB";
    motherboard = mkOption {
      type = types.nullOr (types.enum ["intel" "amd"]);
      default = null;
    };
  };

  config.os.services.hardware.openrgb = mkIf cfg.enable {
    inherit (cfg) motherboard;
    enable = true;
    package = pkgs.openrgb-with-all-plugins;
  };
}
