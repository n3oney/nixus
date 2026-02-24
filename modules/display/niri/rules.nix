{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
  appsWithWorkspace = lib.filterAttrs (
    _: app: app.defaultWorkspace != null && app.windowClass != null
  ) config.applications;
in {
  config = mkIf cfg.enable {
    hm.programs.niri.settings.window-rules =
      lib.mapAttrsToList (_: app: {
        matches = [{app-id = app.windowClass;}];
        open-on-workspace = toString app.defaultWorkspace;
      })
      appsWithWorkspace;
  };
}
