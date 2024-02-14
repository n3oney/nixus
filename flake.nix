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

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
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
    impurity.url = "github:outfoxxed/impurity.nix";
    nix-colors = {url = "github:Misterio77/nix-colors";};
    nix-gaming = {url = "github:fufexan/nix-gaming";};
    nix-super = {url = "github:privatevoid-net/nix-super/ba035e1ea339a97e6ba6a1dd79e0c0e334240234";};
    nixpkgs = {url = "github:nixos/nixpkgs/nixos-unstable";};
    nur = {url = "github:nix-community/NUR";};
    poweroff = {url = "github:n3oney/ha-poweroff";};
    rust-overlay = {url = "github:oxalica/rust-overlay";};
    shadower = {url = "github:n3oney/shadower";};
    uonetplan.url = "github:n3oney/uonetplan";
  };

  outputs = inputs @ {nixpkgs, ...}: let
    forAllSystems = nixpkgs.lib.genAttrs [
      "aarch64-linux"
      "x86_64-linux"
    ];

    combinedManager = import (builtins.fetchTarball {
      url = "https://github.com/flafydev/combined-manager/archive/e7ba6d6b57ee03352022660fcd572c973b6b26db.tar.gz";
      sha256 = "sha256:11raq3s4d7b0crihx8pilhfp74xp58syc36xrsx6hdscyiild1z7";
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
        inherit inputs;
        configuration = {
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/miko
            ./configs/miko
          ];
        };
      };

      # Laptop
      vic = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          modules = [
            ./modules
            ./hosts/vic
            ./configs/vic
          ];
        };
      };
      vic-impure = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          modules = [
            ./modules
            ./hosts/vic
            ./configs/vic
            {os.impurity.enable = true;}
          ];
        };
      };

      # # VPS
      maya = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          modules = [
            ./modules
            ./hosts/maya
            ./configs/maya
          ];
        };
      };

      max = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "x86_64-linux";
          modules = [
            ./modules
            ./hosts/max
            ./configs/max
          ];
        };
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
