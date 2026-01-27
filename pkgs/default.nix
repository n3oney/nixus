{pkgs, ...}: {
  bird = pkgs.callPackage ./overlays/bird {};
  leveldb-cli = pkgs.callPackage ./overlays/leveldb-cli {};
  gg-sans = pkgs.callPackage ./overlays/gg-sans {};
  proton-ge-custom = pkgs.callPackage ./overlays/proton-ge-custom {};
  horizontallyspinningrat = pkgs.callPackage ./overlays/horizontallyspinningrat {};
  mxw = pkgs.callPackage ./overlays/mxw.nix {};
  zed-plex-mono = pkgs.callPackage ./overlays/zed-plex/default.nix {};
  gogcli = pkgs.callPackage ./overlays/gogcli {};
}
