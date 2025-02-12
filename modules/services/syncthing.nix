{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config.os = lib.mkIf config.services.syncthing.enable {
    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      settings.gui = {
        user = "neoney";
        password = "$2a$16$3sJpgx6UK5GBWvD/E5QJFOshPg1DqinP2DIXmIoHXWgreC4rObgJC";
      };
    };

    services.caddy = {
      enable = true;
      virtualHosts."syncthing.neoney.dev".extraConfig = ''
        reverse_proxy http://${osConfig.services.syncthing.guiAddress}
      '';
    };
  };
}
