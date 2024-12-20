{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.webstorm.enable = lib.mkEnableOption "WebStorm";

  config.hm = lib.mkIf config.programs.webstorm.enable {
    home.packages = [pkgs.jetbrains.webstorm];

    home.file.".ideavimrc".text = ''
      set clipboard^=unnamedplus
    '';
  };
}
