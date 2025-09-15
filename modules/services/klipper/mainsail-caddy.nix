{
  osConfig,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.mainsail;
  inherit (osConfig.services) moonraker;
in
{
  options.services.mainsail = {
    enable = mkEnableOption "a modern and responsive user interface for Klipper";

    package = mkPackageOption pkgs "mainsail" { };

    hostName = mkOption {
      type = types.str;
      default = "localhost";
      description = "Hostname to serve mainsail on";
    };

    port = mkOption {
      type = types.port;
      default = 80;
      description = "Port to serve mainsail on";
    };

    caddy = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          extraConfig = '''
            encode gzip
            log {
              output file /var/log/caddy/mainsail.log
            }
          ''';
        }
      '';
      description = "Extra configuration for the Caddy virtual host of mainsail.";
    };
  };

  config.os = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    services.caddy = {
      enable = true;
      virtualHosts."${cfg.hostName}:${toString cfg.port}" = mkMerge [
        cfg.caddy
        {
          extraConfig = ''
            # Set document root
            root * ${cfg.package}/share/mainsail

            # Handle websocket connections first (most specific)
            handle /websocket {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            # Handle API routes - each pattern needs its own handle block
            handle /printer/* {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            handle /api/* {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            handle /access/* {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            handle /machine/* {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            handle /server/* {
              reverse_proxy ${moonraker.address}:${toString moonraker.port}
            }

            # Handle index.html with no-cache headers
            handle /index.html {
              header Cache-Control "no-store, no-cache, must-revalidate"
              file_server
            }

            # Handle all other requests - try file, then directory, then fallback to index.html
            handle {
              try_files {path} {path}/ /index.html
              file_server
            }

            ${cfg.caddy.extraConfig or ""}
          '';
        }
      ];
    };
  };
}
