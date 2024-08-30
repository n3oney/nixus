{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config.hm = lib.mkIf config.programs.zed.enable {
    home.file.".local/share/zed/node/node-v22.5.1-linux-x64" = {
      recursive = true;
      source = "${pkgs.nodejs}";
    };

    home.packages = [
      (pkgs.zed-editor.override {withGLES = true;})
    ];
  };
}
