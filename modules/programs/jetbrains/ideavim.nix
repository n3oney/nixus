{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.programs.rider.enable || config.programs.webstorm.enable) {
    hm.home.file.".ideavimrc".text = ''
      set clipboard^=unnamedplus
    '';
  };
}
