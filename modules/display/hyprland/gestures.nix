{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    hm = {
      wayland.windowManager.hyprland = {
        settings = {
          input = {
            touchpad = {
              natural_scroll = true;
              scroll_factor = 0.3;
            };
          };

          gestures = {
            workspace_swipe_cancel_ratio = 0.15;
          };
        };
      };
    };
  };
}
