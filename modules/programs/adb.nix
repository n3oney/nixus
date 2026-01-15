{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.adb.enable = lib.mkEnableOption "adb";

  config.os = lib.mkIf config.programs.adb.enable {
    users.users.neoney.extraGroups = ["adbusers"];
    environment.systemPackages = [pkgs.android-tools];
  };
}
