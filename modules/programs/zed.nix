{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config.hm.home.packages = lib.mkIf config.programs.zed.enable [
    (pkgs.zed-editor.override {withGLES = true;})
  ];
}
