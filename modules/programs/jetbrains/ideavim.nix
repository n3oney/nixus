{
  config,
  lib,
  ...
}: {
  config = lib.mkIf (config.programs.rider.enable || config.programs.webstorm.enable) {
    h.files.".ideavimrc".text = ''
      set clipboard^=unnamedplus
    '';
  };
}
