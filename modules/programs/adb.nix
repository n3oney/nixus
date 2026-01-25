{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.adb.enable = lib.mkEnableOption "adb";

  config.os = lib.mkIf config.programs.adb.enable {
    environment.systemPackages = [pkgs.android-tools];
    users.users.neoney.extraGroups = ["adbusers"];
  };
}
