_: prev: {
  leveldb-cli = prev.callPackage ./leveldb-cli {};
  gg-sans = prev.callPackage ./gg-sans {};
  proton-ge-custom = prev.callPackage ./proton-ge-custom {};
  horizontallyspinningrat = prev.callPackage ./horizontallyspinningrat {};
  mxw = prev.callPackage ./mxw.nix {};
  android-unpinner = prev.callPackage ./android-unpinner.nix {};
}
