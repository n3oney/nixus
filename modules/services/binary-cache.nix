{
  config,
  osConfig,
  lib,
  ...
}: let
  cfg = config.services.binary-cache;
  thisHost = osConfig.networking.hostName;

  servers = {
    miko = {
      url = "http://miko:5000";
      publicKey = "miko:IggZS8bDV94pcAavbHbSyYaoHPX6Ej7jike0vJogKKw=";
    };
  };

  others = lib.attrValues (lib.filterAttrs (n: _: n != thisHost) servers);
in {
  options.services.binary-cache.server.enable = lib.mkEnableOption "nix-serve binary cache server";

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      # nix-serve (Perl) shells out to the nix CLI — works on Lix, unlike
      # harmonia/nix-serve-ng which speak the frozen daemon protocol directly.
      os.services.nix-serve = {
        enable = true;
        secretKeyFile = osConfig.age.secrets."binary-cache-${thisHost}".path;
        bindAddress = "0.0.0.0";
        port = 5000;
      };
      os.systemd.services.nix-serve.environment.HOME = "/var/empty";
      os.networking.firewall.allowedTCPPorts = [5000];
    })

    {
      os.nix.settings = {
        substituters = map (s: s.url) others;
        trusted-public-keys = map (s: s.publicKey) others;
      };
    }
  ];
}
