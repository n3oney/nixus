{lib, ...}: {
  os.boot.swraid.enable = lib.mkForce false;

  os.environment.etc.currentConfig.source = ../../.;
}
