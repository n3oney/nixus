{
  pkgs,
  lib,
  config,
  ...
}: {
  options.services.mattermost.enable = lib.mkEnableOption "mattermost";

  config.os = lib.mkIf config.services.mattermost.enable {
    services.mattermost = {
      enable = true;
      siteUrl = "https://mattermost.neoney.dev";
    };

    services.caddy = {
      enable = true;
      virtualHosts."mattermost.neoney.dev".extraConfig = ''
        reverse_proxy http://127.0.0.1:8065
      '';
    };
  };
}
