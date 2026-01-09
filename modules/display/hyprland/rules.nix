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

  hasSecondary = cfg.monitors.secondary.name != null;

  chatWorkspaceId =
    if hasSecondary
    then 19
    else 9;

  vesktopWs = chatWorkspaceId;

  # Layer rule helper
  # Usage: mkLayerRule "blur on" "bar-0"
  mkLayerRule = rule: namespace: "${rule}, match:namespace ${namespace}";
in {
  config = lib.mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings = {
      windowrule = [
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
        (mkClassRule "float on" "[Ww]aydroid.*")

        # Browser workspace
        (mkClassRule "workspace 2" "zen")
        (mkClassRule "suppress_event maximize" "zen")

        # Workspace 1 styling (nogap)
        (mkTiledWorkspaceRule "rounding 0" 1)
        (mkTiledWorkspaceRule "border_size 1" 1)

        # Chat workspace styling (tiled windows)
        (mkTiledWorkspaceRule "rounding 0" chatWorkspaceId)
        (mkTiledWorkspaceRule "border_size 1" chatWorkspaceId)

        # Vesktop workspace
        (mkClassRule "workspace ${toString vesktopWs}" "vesktop")
        (mkClassRule "opacity 0.999" "vesktop")

        # Pauseshot
        (mkTitleRule "no_anim on" "PAUSESHOT")
        (mkTitleRule "fullscreen on" "PAUSESHOT")

        # Remove max size limits from all windows
        (mkClassRule "no_max_size on" ".*")
      ];

      layerrule = [
        (mkLayerRule "blur on" "bar-0")
        (mkLayerRule "ignore_alpha 0" "bar-0")
        (mkLayerRule "blur on" "gtk-layer-shell")
        (mkLayerRule "ignore_alpha 0" "gtk-layer-shell")
        (mkLayerRule "blur on" "anyrun")
        (mkLayerRule "ignore_alpha 0.2" "anyrun")
        (mkLayerRule "no_anim on" "anyrun")
        (mkLayerRule "blur on" "notifications")
        (mkLayerRule "ignore_alpha 0" "notifications")

        (mkLayerRule "blur on" "yubikey-state")
        (mkLayerRule "ignore_alpha 0.2" "yubikey-state")

        (mkLayerRule "no_anim on" "selection")
      ];
    };
  };
}
