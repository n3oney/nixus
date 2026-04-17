{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.blender.enable = lib.mkEnableOption "Blender";

  config.h.packages = lib.mkIf config.programs.blender.enable [
    ((pkgs.blender.override {rocmSupport = true;}).overrideAttrs
      (old: {
        cmakeFlags = old.cmakeFlags ++ [(lib.cmakeBool "WITH_CYCLES_OSL" false)];
      }))
  ];
}
