{
  inputs,
  lib,
  osConfig,
  pkgs,
  ...
}: let
  nixSettings = {
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

    accept-flake-config = true;

    extra-experimental-features = ["flakes" "nix-command" "recursive-nix" "ca-derivations"];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
      "https://cache.garnix.io"
      # "https://cache.privatevoid.net"
      "https://attic.kennel.juneis.dog/conduwuit"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      # "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
      "conduwuit:lYPVh7o1hLu1idH4Xt2QHaRa49WRGSAqzcfFd94aOTw="
    ];

    trusted-users = [
      "root"
      "@wheel"
    ];
  };
in {
  hm.nix.settings = nixSettings;

  os = {
    nixpkgs.overlays = [
      (_: prev: {
        # nix-super = inputs.nix-super.packages.${prev.system}.default;
        # nixos-option = prev.nixos-option.override {nix = prev.nixVersions.nix_2_15;};
      })
    ];
    programs.command-not-found.enable = false;

    documentation = {
      enable = true;
      doc.enable = false;
      man.enable = true;
      dev.enable = false;
    };

    nixpkgs.config.permittedInsecurePackages = [
      "cinny-unwrapped-4.2.3"
      "olm-3.2.16"
    ];

    nix = let
      mappedRegistry = lib.mapAttrs (_: v: {flake = v;}) inputs;
    in {
      # package = pkgs.nix-super;
      registry =
        mappedRegistry
        // {
          default = mappedRegistry.nixpkgs;
          nixus = {
            exact = true;
            from = {
              id = "nixus";
              type = "indirect";
            };
            to = {
              path = "/home/neoney/nixus";
              type = "path";
            };
          };
        };

      nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") osConfig.nix.registry;

      gc = {
        # set up garbage collection to run daily,
        # removing unused packages after three days
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 3d";
      };

      settings = nixSettings;
    };
  };

  hm.programs.nix-index.enable = true;
}
