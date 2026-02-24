{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
  autostartApps = lib.filterAttrs (_: app: app.autostart) config.applications;
in {
  config = mkIf cfg.enable {
    hm.programs.niri.settings.spawn-at-startup =
      lib.mapAttrsToList (_: app: {argv = [app.binaryPath];}) autostartApps;
  };
}
