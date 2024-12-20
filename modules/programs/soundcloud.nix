{
  lib,
  config,
  ...
}: let
  cfg = config.programs.soundcloud;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.soundcloud.enable = mkEnableOption "SoundCloud";

  config.hm = mkIf cfg.enable {
    programs.firefox.profiles.soundcloud = {
      name = "SoundCloud";
      id = 3;
    };

    xdg.desktopEntries.soundcloud = {
      name = "SoundCloud";
      comment = "Youtube for TV, on Desktop.";
      exec = "firefox -P \"SoundCloud\" \"https://soundcloud.com/discover\"";
      # icon = ./icon.svg;
      type = "Application";
      terminal = false;
    };
  };
}
