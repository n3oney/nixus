{
  inputs = {
    nix-super.url = "github:privatevoid-net/nix-super";
    unfreepkgs = {
      url = "github:n3oney/unfreepkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  add = {nix-super, ...}: {
    overlays = _: [
      nix-super.overlays.default
    ];
  };

  system = {
    inputs,
    lib,
    config,
    ...
  }:
    with lib; {
      programs.command-not-found.enable = false;

      documentation = {
        enable = true;
        doc.enable = false;
        man.enable = true;
        dev.enable = false;
      };

      nix = let
        mappedRegistry = mapAttrs (_: v: {flake = v;}) inputs;
      in {
        registry =
          mappedRegistry
          // {
            default = mappedRegistry.unfreepkgs;
          };

        nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") config.nix.registry;

        gc = {
          # set up garbage collection to run daily,
          # removing unused packages after three days
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 3d";
        };

        settings = {
          # Free up to 20GiB whenever there is less than 5GB left.
          # this setting is in bytes, so we multiply with 1024 thrice
          min-free = "${toString (5 * 1024 * 1024 * 1024)}";
          max-free = "${toString (20 * 1024 * 1024 * 1024)}";
          # automatically optimise symlinks
          auto-optimise-store = true;

          builders-use-substitutes = true;

          keep-going = true;
          # show more log lines for failed builds
          log-lines = 30;

          max-jobs = "auto";
          sandbox = true;

          warn-dirty = false;

          # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
          http-connections = 0;

          keep-derivations = true;
          keep-outputs = true;

          extra-experimental-features = ["flakes" "nix-command" "recursive-nix" "ca-derivations"];

          substituters = [
            "https://nix-community.cachix.org"
            "https://hyprland.cachix.org"
            "https://cache.privatevoid.net"
          ];
          trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
            "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
          ];

          trusted-users = [
            "root"
            "@wheel"
          ];
        };
      };
    };

  home = _: {
    programs.nix-index.enable = true;
  };
}
