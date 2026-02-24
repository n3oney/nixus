{
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf listToAttrs flatten;

  # Convert transform string (Hyprland int) to niri rotation int
  toRotation = t:
    {
      "0" = 0;
      "1" = 90;
      "2" = 180;
      "3" = 270;
    }
    .${t} or 0;

  mkOutput = monitor: {
    name = monitor.name;
    value = {
      scale = monitor.scale;
      transform.rotation = toRotation monitor.transform;
      position = lib.mkIf (monitor.position != "auto") (let
        parts = lib.splitString "x" monitor.position;
      in {
        x = lib.toInt (builtins.elemAt parts 0);
        y = lib.toInt (builtins.elemAt parts 1);
      });
      mode = {
        width = monitor.width;
        height = monitor.height;
        refresh = monitor.refreshRate * 1.0;
      };
    };
  };
in {
  config = mkIf cfg.enable {
    hm.programs.niri.settings.outputs =
      listToAttrs (map mkOutput cfg.monitors);

    hm.programs.niri.settings.workspaces =
      listToAttrs (flatten (map (
          monitor:
            map (ws: let
              id =
                if builtins.isInt ws
                then ws
                else ws.id;
            in {
              name = lib.fixedWidthString 2 "0" (toString id);
              value = {
                name = toString id;
                open-on-output = monitor.name;
              };
            })
            monitor.workspaces
        )
        cfg.monitors));
  };
}
