{pkgs, ...}: {
  os.nixpkgs.overlays = [(import ../../pkgs/overlays)];
}
