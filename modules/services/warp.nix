{
  lib,
  config,
  ...
}: {
  options.services.warp.enable = lib.mkEnableOption "Cloudflare Warp";

  config.os = lib.mkIf config.services.warp.enable {
    services.cloudflare-warp = {
      enable = true;
    };
  };
}
