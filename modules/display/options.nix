# Shared display options consumed by all compositor subtrees (hyprland, niri, etc.)
{lib, ...}: let
  inherit (lib) mkEnableOption mkOption types;
in {
  options.display = {
    enable = mkEnableOption "Display";

    keyboards = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of keyboard device names for layout switching";
    };

    mouseSensitivity = mkOption {
      type = types.float;
      default = 0;
      description = "Mouse sensitivity (flat accel profile)";
    };

    deviceOverrides = mkOption {
      type = types.listOf (types.attrsOf types.anything);
      default = [];
      description = "Per-device input overrides (e.g., sensitivity)";
    };

    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor name (e.g., DP-1, HDMI-A-1)";
          };
          width = mkOption {
            type = types.int;
            description = "Monitor width in pixels";
          };
          height = mkOption {
            type = types.int;
            description = "Monitor height in pixels";
          };
          refreshRate = mkOption {
            type = types.int;
            default = 60;
            description = "Monitor refresh rate in Hz";
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "Monitor scale factor";
          };
          position = mkOption {
            type = types.str;
            default = "auto";
            description = "Monitor position (e.g., '0x0', 'auto-right', '317x1440')";
          };
          transform = mkOption {
            type = types.str;
            default = "0";
            description = "Monitor transform (rotation)";
          };
          isMain = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this is the main monitor";
          };
          workspaces = mkOption {
            type = types.listOf (types.either types.int (types.submodule {
              options = {
                id = mkOption {
                  type = types.int;
                  description = "Workspace ID";
                };
                default = mkOption {
                  type = types.bool;
                  default = false;
                  description = "Whether this is the default workspace for this monitor";
                };
                gapsIn = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  description = "Inner gaps override for this workspace";
                };
                gapsOut = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  description = "Outer gaps override for this workspace";
                };
                border = mkOption {
                  type = types.nullOr types.bool;
                  default = null;
                  description = "Border override for this workspace";
                };
              };
            }));
            default = [];
            description = "List of workspaces assigned to this monitor";
          };
          workspaceMod = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Modifier keys for workspace keybinds (e.g., 'SUPER'). If null, no keybinds are generated.";
          };
          workspaceKey = mkOption {
            type = types.nullOr (types.functionTo types.str);
            default = null;
            description = "Function: workspace id -> key string. Used with workspaceMod to generate keybinds.";
          };
        };
      });
      default = [];
      description = "List of monitors";
    };

    screenshotKeybinds = {
      active = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Keybind for active window screenshot";
      };
      area = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Keybind for area screenshot";
      };
      all = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Keybind for full screenshot";
      };
      monitor = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Keybind for monitor screenshot";
      };
    };
  };
}
