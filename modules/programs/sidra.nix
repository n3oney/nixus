{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.programs.sidra;
in {
  options.programs.sidra.enable = lib.mkEnableOption "Sidra";

  config = lib.mkIf cfg.enable {
    hm.home.packages = [
      inputs.sidra.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    impermanence.userDirs = [
      ".config/Sidra"
      ".cache/sidra"
    ];
  };
}
