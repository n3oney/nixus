{motherboard ? null, ...}: {
  system = {pkgs, ...}: {
    services.hardware.openrgb = {
      inherit motherboard;
      enable = true;
      package = pkgs.openrgb-with-all-plugins;
    };
  };
}
