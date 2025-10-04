{
  config,
  lib,
  ...
}: let
  cfg = config.services.spoolman;
in {
  options.services.spoolman = {
    enable = lib.mkEnableOption "Spoolman, a filament spool inventory management system.";
    
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Open the appropriate ports in the firewall for spoolman.
      '';
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "The IP address to bind the spoolman server to.";
    };
  };

  config.os = lib.mkIf cfg.enable {
    services.spoolman = {
      enable = true;
      inherit (cfg) openFirewall listen;
    };
  };
}