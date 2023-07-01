{
  config,
  lib,
  ...
}: {
  options.services.arr.enable = lib.mkEnableOption "*arr";
  options.services.arr.group = {
    name = lib.mkOption {
      type = lib.types.str;
      default = "arr";
    };
    gid = lib.mkOption {
      type = lib.types.int;
      default = 1337;
    };
  };

  config.os = lib.mkIf config.services.arr.enable {
    users.groups."${config.services.arr.group.name}" = {
      inherit (config.services.arr.group) gid;
    };
  };
}
