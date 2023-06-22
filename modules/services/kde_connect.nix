{lib, ...}: {
  os.networking.firewall = {
    allowedTCPPorts = lib.range 1714 1764;
    allowedUDPPorts = lib.range 1714 1764;
  };

  hm.services.kdeconnect.enable = true;
}
