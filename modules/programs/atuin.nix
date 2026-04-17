{
  config,
  lib,
  ...
}: {
  options.programs.atuin.enable = lib.mkEnableOption "atuin";

  config = lib.mkIf config.programs.atuin.enable {
    impermanence.userDirs = [".local/share/atuin"];

    hm.programs.atuin = {
      enable = true;
      daemon.enable = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://api.atuin.sh";
      };
    };
  };
}
