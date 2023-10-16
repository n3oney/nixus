{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.minecraft.enable = lib.mkEnableOption "Minecraft";

  config.hm = lib.mkIf config.programs.gaming.minecraft.enable {
    home.packages = [pkgs.prismlauncher];
  };
}
