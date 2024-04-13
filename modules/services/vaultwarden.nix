{
  config,
  lib,
  ...
}: {
  options.services.vaultwarden = {
    enable = lib.mkEnableOption "Vaultwarden";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8222;
    };
  };

  config.os = let
    cfg = config.services.vaultwarden;
  in (lib.mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;

      config = {
        DOMAIN = "https://bitwarden.neoney.dev";
        SIGNUPS_ALLOWED = false;

        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = cfg.port;
      };
    };

    services.caddy = {
      enable = true;

      virtualHosts."bitwarden.neoney.dev".extraConfig = ''
        reverse_proxy 127.0.0.1:${builtins.toString cfg.port}
      '';
    };
  });
}
