{
  config,
  lib,
  ...
}: {
  options.services.tlp.enable = lib.mkEnableOption false;

  config.os.services.tlp.enable = config.services.tlp.enable;
}
