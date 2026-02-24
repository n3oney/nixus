{lib, ...}:
with lib;
with types; {
  options.applications = mkOption {
    default = {};
    type = attrsOf (submodule {
      options = {
        autostart = mkEnableOption "autostart";
        binaryPath = mkOption {type = str;};
        defaultWorkspace = mkOption {
          type = nullOr number;
          default = null;
        };
        windowClass = mkOption {
          type = nullOr str;
          default = null;
        };
        defaultColumnWidth = mkOption {
          type = nullOr float;
          default = null;
          description = "Default column width as a proportion (e.g. 0.75 for 75%)";
        };
        type = mkOption {
          type = enum ["app" "daemon"];
          default = "app";
        };
        blockFromScreencast = mkEnableOption "block window from screencasts";
        hyprlandWindowRules = mkOption {
          type = listOf str;
          default = [];
        };
      };
    });
  };
}
