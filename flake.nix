{
  description = "neoney's NixOS config flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    hyprpaper.url = "github:hyprwm/hyprpaper";
    hyprpicker.url = "github:hyprwm/hyprpicker";

    hyprcontrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    anyrun = {
      url = "github:kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-flake.url = "/home/neoney/code/neovim-flake";

    arrpc = {
      url = "github:notashelf/arrpc-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    poweroff.url = "/home/neoney/code/poweroff";
  };

  outputs = inputs @ {
    nixpkgs,
    home-manager,
    hyprland,
    ...
  }: let
    pcVars = import ./vars/pc.nix;
    utils = import ./utils.nix;
  in {
    nixosConfigurations = {
      nixuspc = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          vars = pcVars;
        };
        system = "x86_64-linux";
        modules = [
          hyprland.nixosModules.default
          ./system
          {programs.hyprland.enable = true;}
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.neoney = import ./home;
              extraSpecialArgs = {inherit utils;};
            };
          }
        ];
      };
    };
  };
}
