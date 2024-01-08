_: prev: {
  leveldb-cli = prev.callPackage ./leveldb-cli {};
  gg-sans = prev.callPackage ./gg-sans {};
  twilio-sans-mono-nerd-font = prev.callPackage ./twilio-sans-mono-nerd-font {};
  proton-ge-custom = prev.callPackage ./proton-ge-custom {};
  horizontallyspinningrat = prev.callPackage ./horizontallyspinningrat {};
  mxw = prev.callPackage ./mxw.nix {};
  android-unpinner = prev.callPackage ./android-unpinner.nix {};
}
