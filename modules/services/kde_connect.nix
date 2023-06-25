{
  lib,
  config,
  ...
}: {
  options.services.kde_connect.enable = lib.mkEnableOption "kde_connect";

  config.os.networking.firewall = lib.mkIf config.services.kde_connect.enable {
    allowedTCPPorts = lib.range 1714 1764;
    allowedUDPPorts = lib.range 1714 1764;
  };

  config.hm.home.persistence."/persist/home/neoney".directories = lib.mkIf (config.services.kde_connect.enable && config.impermanence.enable) [".config/kdeconnect"];

  config.hm.services.kdeconnect.enable = config.services.kde_connect.enable;
}
