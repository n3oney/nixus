{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing";
    openToInternet = lib.mkEnableOption "Open to internet";
  };

  config = lib.mkIf config.services.syncthing.enable {
    impermanence.systemDirs = ["/var/lib/syncthing/.config/syncthing"];

    os = {
      services.syncthing = {
        enable = true;
        openDefaultPorts = true;
        settings.gui = {
          user = "neoney";
          password = "$2a$16$3sJpgx6UK5GBWvD/E5QJFOshPg1DqinP2DIXmIoHXWgreC4rObgJC";
        };
      };

      services.caddy = lib.mkIf config.services.syncthing.openToInternet {
        enable = true;
        virtualHosts."syncthing.neoney.dev".extraConfig = ''
          reverse_proxy http://${osConfig.services.syncthing.guiAddress} {
            header_up Host {upstream_hostport}
          }
        '';
      };
    };
  };
}
