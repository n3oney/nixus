{
  lib,
  config,
  ...
}: {
  options.services.sunshine.enable = lib.mkEnableOption "Sunshine";

  config = lib.mkIf config.services.sunshine.enable {
    impermanence.userDirs = [".config/sunshine"];
    os.services.sunshine = {
      enable = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
