{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    ./palette.nix
    ./settings.nix
  ];

  options.display.noctalia.enable = lib.mkEnableOption "Noctalia";

  config = lib.mkIf config.display.noctalia.enable {
    hmModules = [inputs.noctalia.homeModules.default];

    hm = {
      programs.noctalia = {
        enable = true;
        package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      };

      programs.niri.settings.spawn-at-startup = [{command = ["noctalia"];}];
    };
  };
}
