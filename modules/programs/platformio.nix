{
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.platformio.enable = lib.mkEnableOption "PlatformIO";

  config = lib.mkIf config.programs.platformio.enable {
    os.services.udev.packages = [pkgs.platformio-core.udev pkgs.openocd];
    impermanence.userDirs = [".platformio"];
    hm.home.packages = [pkgs.platformio];
  };
}
