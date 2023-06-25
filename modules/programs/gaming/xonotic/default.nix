{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.xonotic.enable = lib.mkEnableOption "xonotic";

  config.hm = lib.mkIf config.programs.xonotic.enable {
    home.packages = [pkgs.xonotic];

    home.file.".xonotic/data/config.cfg".text = builtins.readFile ./config.cfg;

    home.persistence."/persist/home/neoney".directories = lib.mkIf config.impermanence.enable [".xonotic"];
  };
}
