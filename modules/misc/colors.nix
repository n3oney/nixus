{
  inputs,
  config,
  lib,
  ...
}: {
  options.colors = {
    colorScheme = lib.mkOption {
      default =
        inputs.nix-colors.colorSchemes.catppuccin-macchiato
        // {
          colors =
            inputs.nix-colors.colorSchemes.catppuccin-macchiato.colors
            // {
              accent = "f5bde6";
            };
        };
    };
    backgroundAlpha = lib.mkOption {
      type = lib.types.float;
      default = 0.7;
    };
  };

  config.inputs = {
    nix-colors.url = "github:Misterio77/nix-colors";
  };

  config.hmModules = [inputs.nix-colors.homeManagerModules.default];

  config.hm.colorScheme = config.colors.colorScheme;
}
