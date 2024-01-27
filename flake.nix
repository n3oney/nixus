{
  description = "neoney's NixOS config flake";

  inputs = {
    agenix = {url = "github:ryantm/agenix";};
    ags = {url = "github:Aylur/ags";};
    anyrun = {url = "github:kirottu/anyrun";};
    anyrun-ha-assist = {url = "github:n3oney/anyrun-ha-assist";};
    anyrun-nixos-options = {url = "github:n3oney/anyrun-nixos-options/v2.0.0";};
    apple-silicon-support = {url = "github:tpwrules/nixos-apple-silicon";};
    arrpc = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:notashelf/arrpc-flake";
    };
    btop = {
      flake = false;
      url = "github:catppuccin/btop";
    };
    catppuccin-lemmy = {url = "github:n3oney/catppuccin-lemmy";};
    conduit = {url = "gitlab:famedly/conduit/next";};
    eww = {
      inputs = {
        nixpkgs = {follows = "nixpkgs";};
        rust-overlay = {follows = "rust-overlay";};
      };
      url = "github:ralismark/eww/tray-3";
    };
    home-manager = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:nix-community/home-manager";
    };
    hyprcontrib = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:hyprwm/contrib";
    };
    hyprland = {url = "github:hyprwm/hyprland";};
    hyprpaper = {url = "github:hyprwm/hyprpaper";};
    hyprpicker = {url = "github:hyprwm/hyprpicker";};
    impermanence = {url = "github:nix-community/impermanence";};
    nh = {
      inputs = {nixpkgs = {follows = "nixpkgs";};};
      url = "github:viperML/nh";
    };
    nix-colors = {url = "github:Misterio77/nix-colors";};
    nix-gaming = {url = "github:fufexan/nix-gaming";};
    nix-super = {url = "github:privatevoid-net/nix-super/ba035e1ea339a97e6ba6a1dd79e0c0e334240234";};
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};
    nur = {url = "github:nix-community/NUR";};
    poweroff = {url = "github:n3oney/ha-poweroff";};
    rust-overlay = {url = "github:oxalica/rust-overlay";};
    shadower = {url = "github:n3oney/shadower";};
    uonetplan = {url = "git+ssh://git@github.com/n3oney/uonetplan";};
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
