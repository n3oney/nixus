{
  system = {lib, ...}:
    with lib; {
      networking.firewall = {
        allowedTCPPorts = range 1714 1764;
        allowedUDPPorts = range 1714 1764;
      };
    };

  home = _: {
    services.kdeconnect.enable = true;
  };
}
