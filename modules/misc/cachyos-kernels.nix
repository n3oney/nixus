{inputs, ...}: {
  os.nixpkgs.overlays = [
    inputs.nix-cachyos-kernel.overlays.pinned
  ];
}
