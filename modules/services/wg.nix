{
  osConfig,
  config,
  lib,
  ...
}: {
  options.services.wg.enable = lib.mkEnableOption "wg";

  config.os = lib.mkIf config.services.wg.enable {
    networking.wg-quick.interfaces.wg0 = {
      configFile = osConfig.age.secrets.wg.path;
    };
  };
}
