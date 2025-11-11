{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.thunderbird.enable = lib.mkEnableOption "thunderbird";

  config.impermanence.userDirs = lib.mkIf config.programs.thunderbird.enable [".thunderbird"];

  config.hm.programs.thunderbird = lib.mkIf config.programs.thunderbird.enable {
    enable = true;
    package =
      if pkgs.system == "x86-64-linux"
      then pkgs.thunderbird-bin
      else pkgs.thunderbird;
    profiles.default = {
      isDefault = true;
      settings = {};
      userChrome = "";
      userContent = "";
      withExternalGnupg = true;
    };
  };
}
