{
  inputs = {
    nix-super.url = "github:privatevoid-net/nix-super";
  };

  add = {nix-super, ...}: {
    overlays = _: [
      nix-super.overlays.default
    ];
  };

  system = {inputs, ...}: {
    programs.command-not-found.enable = false;

    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      nixPath = [
        "nixpkgs=${inputs.nixpkgs}"
      ];
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        auto-optimise-store = true;
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
          "cache.privatevoid.net:SErQ8bvNWANeAvtsOESUwVYr2VJynfuc9JRwlzTTkVg="
        ];
        substituters = [
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
          "https://cache.privatevoid.net"
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
