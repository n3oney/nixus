{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.discord.useDissent = lib.mkEnableOption "Use dissent instead of web client.";

  config = lib.mkIf (config.programs.discord.enable && config.programs.discord.useDissent) (let
    package = inputs.dissent.packages.${pkgs.system}.default;
  in {
    applications.discord = {
      autostart = true;
      binaryPath = lib.getExe package;
      defaultWorkspace = 19;
      windowClass = "so.libdb.dissent";
    };

    impermanence.userDirs = [".config/dissent"];

    hm.home.packages = [package];
  });
}
