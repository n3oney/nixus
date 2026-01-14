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
        type = mkOption {
          type = enum ["app" "daemon"];
          default = "app";
        };
        hyprlandWindowRules = mkOption {
          type = listOf str;
          default = [];
        };
      };
    });
  };
}
