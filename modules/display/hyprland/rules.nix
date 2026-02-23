{
  config,
  lib,
  ...
}: let
  cfg = config.display;

  # Helper to create a window rule
  # Usage: mkRule "immediate on" "class ^(cs2)$"
  mkRule = rule: matcher: "${rule}, match:${matcher}";

  # Helper for class matching
  mkClassRule = rule: regex: mkRule rule "class ^(${regex})$";

  # Helper for title matching
  mkTitleRule = rule: regex: mkRule rule "title ^(${regex})$";

  # Helper for workspace matching (applies only to tiled windows for styling)
  mkTiledWorkspaceRule = rule: workspaceId: mkRule rule "workspace ${toString workspaceId}, match:float false";

  # Normalize workspace entry (int or submodule -> consistent attrs)
  normalizeWs = ws:
    if builtins.isInt ws
    then {
      id = ws;
      default = false;
      gapsIn = null;
      gapsOut = null;
      border = null;
    }
    else ws;

  # Compute list of workspaces with no gaps (gapsIn == 0 or gapsOut == 0)
  noGapWorkspaces = lib.flatten (map (monitor:
      map (ws: (normalizeWs ws).id)
        (lib.filter (ws: let
            w = normalizeWs ws;
          in
            (w.gapsIn or null) == 0 || (w.gapsOut or null) == 0)
          monitor.workspaces))
    cfg.monitors);

  appsToAssignToWorkspaces =
    lib.filterAttrs (
      k: app: app.defaultWorkspace != null && app.windowClass != null
    )
    config.applications;
  appWorkspaceRules =
    lib.mapAttrsToList (
      k: application:
        mkClassRule "workspace ${toString application.defaultWorkspace}" application.windowClass
    )
    appsToAssignToWorkspaces;

  appHyprlandWindowRules = lib.flatten (
    lib.mapAttrsToList (
      k: application:
        map (ruleContent: mkClassRule ruleContent application.windowClass) application.hyprlandWindowRules
    )
    config.applications
  );
  # Layer rule helper
  # Usage: mkLayerRule "blur on" "bar-0"
  mkLayerRule = rule: namespace: "${rule}, match:namespace ${namespace}";
in {
  config = lib.mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      windowrule =
        [
          # Gaming - tearing and fullscreen suppression
          (mkClassRule "immediate on" "cs2")
          (mkClassRule "suppress_event fullscreen" "cs2")
          (mkClassRule "suppress_event maximize" "cs2")
          (mkClassRule "immediate on" "Minecraft.*")

          # Misc window rules
          (mkClassRule "no_blur on" "Xdg-desktop-portal-gtk")
          (mkClassRule "pin on" "ssh-askpass")
          (mkClassRule "float on" "ssh-askpass")
          (mkTitleRule "idle_inhibit focus" "YouTube on TV.*")
          (mkClassRule "idle_inhibit fullscreen" ".*")

          # Pauseshot
          (mkTitleRule "no_anim on" "PAUSESHOT")
          (mkTitleRule "fullscreen on" "PAUSESHOT")

          # Remove max size limits from all windows
          (mkClassRule "no_max_size on" ".*")
        ]
        # Apply no-gap workspace styling (rounding 0, border_size 1) to tiled windows
        ++ (lib.flatten (map (wsId: [
              (mkTiledWorkspaceRule "rounding 0" wsId)
              (mkTiledWorkspaceRule "border_size 1" wsId)
            ])
            noGapWorkspaces))
        ++ appWorkspaceRules
        ++ appHyprlandWindowRules;

      layerrule = [
        (mkLayerRule "blur on" "bar")
        (mkLayerRule "no_anim on" "bar")
        (mkLayerRule "blur on" "bar-0")
        (mkLayerRule "ignore_alpha 0" "bar-0")
        (mkLayerRule "no_anim on" "bar-0")
        (mkLayerRule "blur on" "gtk-layer-shell")
        (mkLayerRule "ignore_alpha 0" "gtk-layer-shell")
        (mkLayerRule "blur on" "vicinae")
        (mkLayerRule "ignore_alpha 0.2" "vicinae")
        (mkLayerRule "no_anim on" "vicinae")
        (mkLayerRule "blur on" "notifications")
        (mkLayerRule "ignore_alpha 0" "notifications")

        (mkLayerRule "blur on" "yubikey-state")
        (mkLayerRule "ignore_alpha 0.2" "yubikey-state")

        (mkLayerRule "no_anim on" "selection")
      ];
    };
  };
}
