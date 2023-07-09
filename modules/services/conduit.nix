{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.conduit.enable = lib.mkEnableOption "conduit";

  config.os.services.matrix-conduit = lib.mkIf config.services.conduit.enable {
    enable = true;
    settings.global = {
      server_name = "neoney.dev";
      # allow_registration = true;
      database_backend = "rocksdb";
    };
  };

  config.os.services.caddy = lib.mkIf config.services.conduit.enable {
    enable = true;
    virtualHosts."matrix.neoney.dev".extraConfig = ''
      reverse_proxy /_matrix/* localhost:${toString osConfig.services.matrix-conduit.settings.global.port}
    '';
  };
}
