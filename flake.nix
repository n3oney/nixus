{
  description = "neoney's NixOS config flake";

  inputs = {
    agenix.url = "github:ryantm/agenix";
    awww.url = "git+https://codeberg.org/LGFae/awww";

    btop-rose-pine = {
      flake = false;
      url = "github:rose-pine/btop";
    };
    degra-ical.url = "github:n3oney/degra-ical";
    dissent.url = "github:diamondburned/dissent";
    EffectPatterns = {
      url = "github:PauljPhilp/EffectPatterns";
      flake = false;
    };
    fcitx-virtualkeyboard-adapter = {
      url = "github:horriblename/fcitx-virtualkeyboard-adapter";
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
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
    preservation.url = "github:nix-community/preservation";
    nh = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:viperML/nh";
    };
    nix-ai-tools.url = "github:numtide/nix-ai-tools";
    llama-cpp = {
      url = "github:ggml-org/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:Misterio77/nix-colors";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    niri-blur = {
      url = "github:niri-wm/niri/wip/branch";
      flake = false;
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.niri-unstable.follows = "niri-blur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    opencode-notifier = {
      url = "github:mohak34/opencode-notifier";
      flake = false;
    };

    shadower.url = "github:n3oney/shadower";
    zen-browser-flake.url = "github:youwen5/zen-browser-flake";
    jj-starship.url = "github:dmmulroy/jj-starship";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvf.url = "github:NotAShelf/nvf";
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vicinae.url = "github:vicinaehq/vicinae";
    wayscriber.url = "github:devmobasa/wayscriber";
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
          specialArgs = {sources = nixpkgs.legacyPackages.x86_64-linux.callPackage ./_sources/generated.nix {};};
          modules = [
            ./modules
            ./hosts/miko
            ./configs/miko
          ];
        };
      };

      # VPS
      yen = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "aarch64-linux";
          specialArgs = {sources = nixpkgs.legacyPackages.aarch64-linux.callPackage ./_sources/generated.nix {};};
          modules = [
            ./modules
            ./hosts/yen
            ./configs/yen
          ];
        };
      };

      endurance = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "x86_64-linux";
          specialArgs = {sources = nixpkgs.legacyPackages.x86_64-linux.callPackage ./_sources/generated.nix {};};
          modules = [
            ./modules
            ./hosts/endurance
            ./configs/endurance
          ];
        };
      };

      # Tablet (Minisforum V3)
      prism = combinedManager.nixosSystem {
        inherit inputs;
        configuration = {
          system = "x86_64-linux";
          specialArgs = {sources = nixpkgs.legacyPackages.x86_64-linux.callPackage ./_sources/generated.nix {};};
          modules = [
            ./modules
            ./hosts/prism
            ./configs/prism
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

            nvfetcher

            # quickshell lsp
            kdePackages.qtdeclarative
          ];
        }
    );
  };
}
