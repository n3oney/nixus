{lib, ...}: {
  os.boot.swraid.enable = lib.mkForce false;
}
