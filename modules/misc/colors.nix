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
            inputs.nix-colors.colorSchemes.catppuccin-macchiato.palette
            // {
              accent = "f5bde6";
            };
        };
    };
    backgroundAlpha = lib.mkOption {
      type = lib.types.float;
      default = 0.9;
    };
  };

  config.hmModules = [inputs.nix-colors.homeManagerModules.default];

  config.hm.colorScheme = config.colors.colorScheme;
}
