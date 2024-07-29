{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config.hm.home.packages = lib.mkIf config.programs.zed.enable [
    (inputs.nixpkgs-master.legacyPackages.${pkgs.system}.zed-editor.override {withGLES = true;})
  ];
}
