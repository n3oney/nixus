{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.discord.useDissent = lib.mkEnableOption "Use dissent instead of web client.";

  config = lib.mkIf (config.programs.discord.enable && config.programs.discord.useDissent) {
    impermanence.userDirs = [".config/dissent"];

    hm.home.packages = [inputs.dissent.packages.${pkgs.system}.default];
  };
}
