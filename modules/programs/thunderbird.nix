{
  config,
  lib,
  ...
}: {
  options.programs.thunderbird.enable = lib.mkEnableOption "thunderbird";

  config.hm.programs.thunderbird = lib.mkIf config.programs.thunderbird.enable {
    enable = true;
    profiles.default = {
      isDefault = true;
      settings = {};
      userChrome = "";
      userContent = "";
      withExternalGnupg = true;
    };
  };
}
