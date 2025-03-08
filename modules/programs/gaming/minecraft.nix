{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.gaming.minecraft.enable = lib.mkEnableOption "Minecraft";

  config = lib.mkIf config.programs.gaming.minecraft.enable {
    hm.home.packages = [pkgs.prismlauncher pkgs.glfw-wayland-minecraft];

    impermanence.userDirs = [".local/share/PrismLauncher"];
  };
}
