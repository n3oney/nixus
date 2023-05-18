{
  description = "neoney's NixOS config flake";
  inputs = import ./utils/mk-system-inputs-init.nix {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {nixpkgs, ...}: {
    nixosConfigurations = {
      nixuspc = nixpkgs.lib.nixosSystem (
        import ./profiles/desktop.nix (import ./utils/mk-system.nix) {
          inherit inputs;
          system = import ./systems/desktop;
        }
      );
    };
  };
}
