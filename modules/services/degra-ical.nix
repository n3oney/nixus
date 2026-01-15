{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.services.degra-ical = {
    enable = lib.mkEnableOption "degra-ical";
    port = lib.mkOption {
      default = 41235;
      type = lib.types.int;
    };
  };

  config.os = let
    cfg = config.services.degra-ical;
  in
    lib.mkIf config.services.degra-ical.enable {
      services.caddy = {
        enable = true;
        virtualHosts."degra-ical.neoney.dev".extraConfig = ''
          reverse_proxy 127.0.0.1:${builtins.toString cfg.port}
        '';
      };

      networking.firewall.allowedTCPPorts = [80 443];

      systemd.services.degra-ical = {
        enable = true;
        description = "degra-ical";
        wantedBy = ["multi-user.target"];
        after = ["network-online.target"];
        requires = ["network-online.target"];
        environment = {
          PORT = builtins.toString cfg.port;
        };
        serviceConfig = {
          Restart = "on-failure";
          RestartSec = "5s";
          ExecStart = "${inputs.degra-ical.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/degra-ical";
        };
      };
    };
}
