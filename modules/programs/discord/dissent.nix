{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  options.programs.discord.useDissent = lib.mkEnableOption "Use dissent instead of web client.";

  config = lib.mkIf (config.programs.discord.enable && config.programs.discord.useDissent) (let
    package = inputs.dissent.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    applications.discord = {
      autostart = true;
      binaryPath = "${package}/bin/dissent";
      defaultWorkspace = lib.mkDefault 19;
      windowClass = "so.libdb.dissent";
    };

    impermanence.userDirs = [".config/dissent"];

    hm.home.packages = [package];
  });
}
