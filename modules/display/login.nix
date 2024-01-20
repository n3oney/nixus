{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  config = lib.mkIf config.display.enable {
    os = let
      toHyprconf = with lib;
        attrs: indentLevel: let
          indent = concatStrings (replicate indentLevel "  ");

          mkSection = n: attrs: ''
            ${indent}${n} {
            ${toHyprconf attrs (indentLevel + 1)}${indent}}
          '';
          sections = filterAttrs (n: v: isAttrs v) attrs;

          mkFields = generators.toKeyValue {
            listsAsDuplicateKeys = true;
            inherit indent;
          };
          allFields = filterAttrs (n: v: !(isAttrs v)) attrs;
          importantFields =
            filterAttrs (n: _: (hasPrefix "$" n) || (hasPrefix "bezier" n))
            allFields;
          fields =
            builtins.removeAttrs allFields
            (mapAttrsToList (n: _: n) importantFields);
        in
          mkFields importantFields
          + concatStringsSep "\n" (mapAttrsToList mkSection sections)
          + mkFields fields;

      hyprlandCfg = hmConfig.wayland.windowManager.hyprland.settings;

      greetdHyprlandConfig = pkgs.writeText "greetd-hyprland-config" (toHyprconf {
          inherit (hyprlandCfg) input general decoration animations dwindle misc;

          monitor = builtins.filter (v: !(lib.hasInfix "addreserved" v)) hyprlandCfg.monitor;

          # Use GTK theme from ./gtk.nix
          env =
            (hyprlandCfg.env or [])
            ++ [
              "GTK_THEME,${hmConfig.gtk.theme.name}"
            ];

          exec-once = [
            "dbus-update-activation-environment --systemd --all"
            "hyprctl setcursor ${hmConfig.home.pointerCursor.name} ${toString hmConfig.home.pointerCursor.size}"
            # No --layer-shell, because Hyprland doesn't focus it by default.
            "${lib.getExe pkgs.greetd.regreet}; hyprctl dispatch exit"
            "systemctl --user restart xdg-desktop-portal xdg-desktop-portal-hyprland"
          ];
        }
        0);
    in {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${lib.getExe config.display.package} --config ${greetdHyprlandConfig}";
          };
        };
      };

      security.pam.services.greetd.enableGnomeKeyring = true;

      environment.etc."greetd/environments".text = ''
        Hyprland
      '';
    };
  };
}
