{
  description = "neoney's NixOS config flake";

  inputs = let
    combinedManager = import (builtins.fetchTarball {
      url = "https://github.com/flafydev/combined-manager/archive/9474a2432b47c0e6fa0435eb612a32e28cbd99ea.tar.gz";
      sha256 = "sha256:04rzv1ajxrcmjybk1agpv4rpwivy7g8mwfms8j3lhn09bqjqrxxf";
    });
  in
    combinedManager.evaluateInputs {
      lockFile = ./flake.lock;
      initialInputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

        home-manager = {
          url = "github:nix-community/home-manager";
          inputs.nixpkgs.follows = "nixpkgs";
        };
      };

      modules = [
        ./modules
        ./hosts/miko
        ./configs/miko
        ./hosts/vic
        ./configs/vic
        ./configs/maya
        ./hosts/maya
        ./configs/max
        ./hosts/max
      ];
    };

  outputs = inputs @ {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];

    combinedManager = import (builtins.fetchTarball {
      url = "https://github.com/flafydev/combined-manager/archive/9474a2432b47c0e6fa0435eb612a32e28cbd99ea.tar.gz";
      sha256 = "sha256:04rzv1ajxrcmjybk1agpv4rpwivy7g8mwfms8j3lhn09bqjqrxxf";
    });
  in {
    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        import ./pkgs {inherit pkgs;}
    );

    nixosConfigurations = {
      # Desktop
      miko = combinedManager.nixosSystem {
        system = "x86_64-linux";
        inherit inputs;
        modules = [
          ./modules
          ./hosts/miko
          ./configs/miko
        ];
      };

      # Laptop
      vic = combinedManager.nixosSystem {
        system = "aarch64-linux";
        inherit inputs;
        modules = [
          ./modules
          ./hosts/vic
          ./configs/vic
        ];
      };

      # # VPS
      maya = combinedManager.nixosSystem {
        system = "aarch64-linux";
        inherit inputs;
        modules = [
          ./modules
          ./hosts/maya
          ./configs/maya
        ];
      };

      max = combinedManager.nixosSystem {
        system = "x86_64-linux";
        inherit inputs;
        modules = [
          ./modules
          ./hosts/max
          ./configs/max
        ];
      };
    };

    formatter = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.alejandra
    );

    devShell = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra

            # AGS configuring stuff
            nodejs
            nodePackages.typescript-language-server
            nodePackages.prettier
            nodePackages.eslint
          ];
        }
    );
  };
}
