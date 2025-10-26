_: prev: {
  leveldb-cli = prev.callPackage ./leveldb-cli {};
  gg-sans = prev.callPackage ./gg-sans {};
  zed-plex-mono = prev.callPackage ./zed-plex {};
  proton-ge-custom = prev.callPackage ./proton-ge-custom {};
  horizontallyspinningrat = prev.callPackage ./horizontallyspinningrat {};
  mxw = prev.callPackage ./mxw.nix {};
  orca-slicer-nightly = prev.callPackage ./orca-slicer-nightly {};
}
