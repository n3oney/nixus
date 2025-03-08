{
  lib,
  config,
  ...
}: {
  options.services.kde_connect.enable = lib.mkEnableOption "kde_connect";

  config = lib.mkIf config.services.kde_connect.enable {
    os.networking.firewall = {
      allowedTCPPorts = lib.range 1714 1764;
      allowedUDPPorts = lib.range 1714 1764;
    };

    hm.services.kdeconnect.enable = true;

    impermanence.userDirs = [".config/kdeconnect"];
  };
}
