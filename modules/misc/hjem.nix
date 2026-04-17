{
  inputs,
  lib,
  config,
  ...
}: {
  options.h = lib.mkOption {
    type = lib.types.deferredModule;
    default = {};
  };
  config = {
    osModules = [inputs.hjem.nixosModules.default];
    os.hjem.users.neoney = {
      imports = [config.h];
      user = "neoney";
      directory = "/home/neoney";
    };
  };
}
