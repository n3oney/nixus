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
  appsWithRules = lib.filterAttrs (
    _: app: app.windowClass != null && (app.defaultWorkspace != null || app.defaultColumnWidth != null || app.blockFromScreencast)
  ) config.applications;
in {
  config = mkIf cfg.enable {
    hm.programs.niri.settings.window-rules =
      lib.mapAttrsToList (_: app:
        {
          matches = [{app-id = app.windowClass;}];
        }
        // lib.optionalAttrs (app.defaultWorkspace != null) {
          open-on-workspace = toString app.defaultWorkspace;
        }
        // lib.optionalAttrs (app.defaultColumnWidth != null) {
          default-column-width.proportion = app.defaultColumnWidth;
        }
        // lib.optionalAttrs app.blockFromScreencast {
          block-out-from = "screencast";
        })
      appsWithRules;
  };
}
