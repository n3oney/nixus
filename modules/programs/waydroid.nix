{
  lib,
  config,
  ...
}: {
  options.programs.waydroid.enable = lib.mkEnableOption "WayDroid";

  config.os = lib.mkIf config.programs.waydroid.enable {
    virtualisation.waydroid.enable = true;
  };
}
