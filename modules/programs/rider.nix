{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.rider.enable = lib.mkEnableOption "JetBrains Rider";

  config = lib.mkIf config.programs.rider.enable {
    hm.home.packages = [pkgs.jetbrains.rider];

    impermanence.userDirs = [".config/JetBrains" ".local/share/JetBrains"];
  };
}
