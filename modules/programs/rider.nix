{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.rider.enable = lib.mkEnableOption "JetBrains Rider";

  config = lib.mkIf config.programs.rider.enable {
    hm.home.packages = [pkgs.jetbrains.rider pkgs.dotnet-sdk_9];

    impermanence.userDirs = [".java/.userPrefs" ".config/JetBrains" ".local/share/JetBrains" ".cache/JetBrains"];
  };
}
