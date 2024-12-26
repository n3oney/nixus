{
  description = "neoney's NixOS config flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    ags.url = "github:Aylur/ags/v1.9.0";
    anyrun.url = "github:kirottu/anyrun";
    anyrun-ha-assist.url = "github:n3oney/anyrun-ha-assist";
    anyrun-nixos-options.url = "github:n3oney/anyrun-nixos-options/v2.0.0";
    apple-silicon-support.url = "github:tpwrules/nixos-apple-silicon";
    arrpc = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:notashelf/arrpc-flake";
    };
    btop-rose-pine = {
      flake = false;
      url = "github:rose-pine/btop";
    };
    catppuccin-lemmy.url = "github:n3oney/catppuccin-lemmy";
    conduwuit.url = "github:girlbossceo/conduwuit";
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    hyprcontrib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hyprwm/contrib";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    impermanence.url = "github:nix-community/impermanence";
    nh = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:viperML/nh";
    };
    nix-colors.url = "github:Misterio77/nix-colors";
    # nix-super.url = "github:privatevoid-net/nix-super";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-master.url = "github:nixos/nixpkgs";
    nixpkgs-2405.url = "github:nixos/nixpkgs/24.05";
    nur.url = "github:nix-community/NUR";
    rust-overlay.url = "github:oxalica/rust-overlay";
    shadower.url = "github:n3oney/shadower";
    shibabot = {
      url = "git+ssh://git@github.com/n3oney/shibabot2.git";
      flake = false;
    };
    zen-browser.url = "github:fufexan/zen-browser-flake";
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
      ciri = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          modules = [
            ./modules
            ./hosts/ciri
            ./configs/ciri
          ];
        };
      };

      # # VPS
      yen = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          modules = [
            ./modules
            ./hosts/yen
            ./configs/yen
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
