{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: (let cfg = config.programs.quickshell; in {
  options.programs.quickshell = {
    enable = lib.mkEnableOption "quickshell";
    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.quickshell.packages.${pkgs.system}.quickshell;
      description = "The package to use for quickshell";
    };
  };

  config.hm = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."quickshell/bar/shell.qml".source = ./bar/shell.qml;

    xdg.configFile."quickshell/bar/config.js".text = with lib; with builtins; ''
      .pragma library

      const backgroundColor = "#${toHexString (floor (config.colors.backgroundAlpha * 255))}${config.colors.colorScheme.palette.base00}";
    '';
  };
})
