{
  config,
  lib,
  ...
}: {
  options.programs.zoxide.enable = lib.mkEnableOption "zoxide";

  config = lib.mkIf config.programs.zoxide.enable {
    impermanence.userDirs = [".local/share/zoxide"];

    hm.programs.zoxide.enable = true;
  };
}
