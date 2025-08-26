{
  description = "neoney's NixOS config flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    ags.url = "github:Aylur/ags/v1.9.0";
    anyrun.url = "github:kirottu/anyrun";
    anyrun-ha-assist.url = "github:n3oney/anyrun-ha-assist";
    anyrun-nixos-options.url = "github:n3oney/anyrun-nixos-options/v2.0.0";
    apple-silicon-support.url = "github:oliverbestmann/nixos-apple-silicon";
    btop-rose-pine = {
      flake = false;
      url = "github:rose-pine/btop";
    };
    degra-ical.url = "github:n3oney/degra-ical";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager";
    };
    hyprcontrib = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:hyprwm/contrib";
    };
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpicker.url = "github:hyprwm/hyprpicker";
    impermanence.url = "github:nix-community/impermanence";
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.lix = {
        url = "git+https://git.lix.systems/lix-project/lix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };
    # lix-module = {
    #   url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nh = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:viperML/nh";
    };
    nix-colors.url = "github:Misterio77/nix-colors";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    rust-overlay.url = "github:oxalica/rust-overlay";
    shadower.url = "github:n3oney/shadower";
    zen-browser-flake.url = "github:youwen5/zen-browser-flake";
    nvf.url = "github:NotAShelf/nvf";
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
            eslint
          ];
        }
    );
  };
}
