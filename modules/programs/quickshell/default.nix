{
  inputs,
  lib,
  pkgs,
  config,
  hmConfig,
  ...
}: (let
  cfg = config.programs.quickshell;
  palette = config.colors.colorScheme.palette;
  alphaHex = lib.toHexString (builtins.floor (config.colors.backgroundAlpha * 255));
  hyprlandSettings = hmConfig.wayland.windowManager.hyprland.settings;
  gap = hyprlandSettings.general.gaps_out;
  rounding = hyprlandSettings.decoration.rounding;

  # Monitor access
  monitors = config.display.monitors;
  mainMonitor = lib.findFirst (m: m.isMain) (builtins.head monitors) monitors;
  secondaryMonitor =
    if builtins.length monitors > 1
    then (builtins.elemAt monitors 1).name
    else "";
  hasSecondary = builtins.length monitors > 1;

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
    monitors);

  # Parse workspace animation: "workspaces, 1, 7, fluent_decel, slide"
  workspaceAnim = builtins.filter (a: lib.hasPrefix "workspaces," a) hyprlandSettings.animations.animation;
  animationSpeed =
    if workspaceAnim != []
    then builtins.elemAt (lib.splitString ", " (builtins.head workspaceAnim)) 2
    else "7";
  animationBezierName =
    if workspaceAnim != []
    then builtins.elemAt (lib.splitString ", " (builtins.head workspaceAnim)) 3
    else "fluent_decel";

  # Find the bezier curve definition
  bezierDefs = builtins.filter (b: lib.hasPrefix "${animationBezierName}," b) hyprlandSettings.animations.bezier;
  bezierValues =
    if bezierDefs != []
    then let
      parts = lib.splitString ", " (builtins.head bezierDefs);
    in "[${builtins.elemAt parts 1}, ${builtins.elemAt parts 2}, ${builtins.elemAt parts 3}, ${builtins.elemAt parts 4}]"
    else "[0.1, 1, 0, 1]";
in {
  options.programs.quickshell = {
    enable = lib.mkEnableOption "quickshell";
    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
      description = "The package to use for quickshell";
    };
  };

  config.hm = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    # Copy all QML files
    xdg.configFile."quickshell/bar/shell.qml".source = ./bar/shell.qml;
    xdg.configFile."quickshell/bar/Bar.qml".source = ./bar/Bar.qml;
    xdg.configFile."quickshell/bar/components/BarButton.qml".source = ./bar/components/BarButton.qml;
    xdg.configFile."quickshell/bar/widgets/Clock.qml".source = ./bar/widgets/Clock.qml;
    xdg.configFile."quickshell/bar/widgets/Battery.qml".source = ./bar/widgets/Battery.qml;
    xdg.configFile."quickshell/bar/widgets/Volume.qml".source = ./bar/widgets/Volume.qml;
    xdg.configFile."quickshell/bar/widgets/SysTray.qml".source = ./bar/widgets/SysTray.qml;
    xdg.configFile."quickshell/bar/widgets/PowerMenu.qml".source = ./bar/widgets/PowerMenu.qml;
    xdg.configFile."quickshell/bar/widgets/IdleInhibit.qml".source = ./bar/widgets/IdleInhibit.qml;
    xdg.configFile."quickshell/bar/widgets/Sunset.qml".source = ./bar/widgets/Sunset.qml;

    # System tray menu components
    xdg.configFile."quickshell/bar/widgets/systray/MenuCheckBox.qml".source = ./bar/widgets/systray/MenuCheckBox.qml;
    xdg.configFile."quickshell/bar/widgets/systray/MenuRadioButton.qml".source = ./bar/widgets/systray/MenuRadioButton.qml;
    xdg.configFile."quickshell/bar/widgets/systray/MenuChildrenRevealer.qml".source = ./bar/widgets/systray/MenuChildrenRevealer.qml;
    xdg.configFile."quickshell/bar/widgets/systray/MenuItem.qml".source = ./bar/widgets/systray/MenuItem.qml;
    xdg.configFile."quickshell/bar/widgets/systray/MenuView.qml".source = ./bar/widgets/systray/MenuView.qml;

    # Generated config with colors - hot-reloadable
    xdg.configFile."quickshell/bar/config.js".text = ''
      .pragma library

      // Background with alpha
      const backgroundColor = "#${alphaHex}${palette.base00}";
      const foregroundColor = "#${palette.base05}";
      const accentColor = "#${palette.accent}";

      // Full color palette
      const base00 = "#${palette.base00}";
      const base01 = "#${palette.base01}";
      const base02 = "#${palette.base02}";
      const base03 = "#${palette.base03}";
      const base04 = "#${palette.base04}";
      const base05 = "#${palette.base05}";
      const base06 = "#${palette.base06}";
      const base07 = "#${palette.base07}";
      const base08 = "#${palette.base08}";
      const base09 = "#${palette.base09}";
      const base0A = "#${palette.base0A}";
      const base0B = "#${palette.base0B}";
      const base0C = "#${palette.base0C}";
      const base0D = "#${palette.base0D}";
      const base0E = "#${palette.base0E}";
      const base0F = "#${palette.base0F}";

      // Opacity values
      const mutedOpacity = 0.5;
      const subtleOpacity = 0.75;

      // Layout
      const barHeight = 50;
      const spacing = 8;
      const fontSize = 14;
      const fontFamily = "sans";
      const gap = ${toString gap};
      const rounding = ${toString rounding};
      const mainMonitor = "${mainMonitor.name}";
      const secondaryMonitor = "${
        if secondaryMonitor == ""
        then "null"
        else secondaryMonitor
      }";
      const noRoundingWorkspaces = [${lib.concatMapStringsSep ", " toString noGapWorkspaces}];

      // Animation (matches Hyprland workspace animation)
      const animationDuration = ${animationSpeed} * 100;
      const animationBezier = ${bezierValues};
    '';

    systemd.user.services.quickshell = {
      Unit = {
        Description = "Quickshell";
        PartOf = ["graphical-session.target"];
        After = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/quickshell -c bar";
        Restart = "on-failure";
        RestartSec = 3;
        Environment = [
          "QS_ICON_THEME=breeze"
        ];
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  };
})
