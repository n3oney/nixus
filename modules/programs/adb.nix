{
  config,
  lib,
  ...
}: {
  options.programs.adb.enable = lib.mkEnableOption "adb";

  config.os = lib.mkIf config.programs.adb.enable {
    programs.adb.enable = true;
    users.users.neoney.extraGroups = ["adbusers"];
  };
}
