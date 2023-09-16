{inputs, ...}: {
  inputs.nixpak = {
    url = "github:nixpak/nixpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  os.nixpkgs.overlays = [
    (pkgs: _: {
      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit (pkgs) lib;
        inherit pkgs;
      };
    })
  ];
}
