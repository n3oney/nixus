{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.rider.enable = lib.mkEnableOption "JetBrains Rider";

  config = lib.mkIf config.programs.rider.enable {
    hm.home.packages = [pkgs.jetbrains.rider pkgs.msbuild pkgs.dotnet-sdk];

    os.nixpkgs.config.permittedInsecurePackages = [
      "dotnet-sdk-6.0.428"
      "dotnet-runtime-6.0.36"
    ];

    impermanence.userDirs = [".config/JetBrains" ".local/share/JetBrains" ".dotnet"];
  };
}
