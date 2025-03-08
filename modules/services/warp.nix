{
  lib,
  config,
  ...
}: {
  options.services.warp.enable = lib.mkEnableOption "Cloudflare Warp";

  config = lib.mkIf config.services.warp.enable {
    impermanence.systemDirs = ["/var/lib/cloudflare-warp"];
    os = {
      services.cloudflare-warp = {
        enable = true;
      };
    };
  };
}
