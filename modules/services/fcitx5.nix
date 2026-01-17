{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.services.fcitx5.enable = lib.mkEnableOption "fcitx5";

  config = lib.mkIf config.services.fcitx5.enable {
    applications.fcitx5 = {
      autostart = true;
      binaryPath = "${pkgs.fcitx5}/bin/fcitx5 -d";
      type = "daemon";
    };

    applications.wvkbd = {
      autostart = true;
      binaryPath = "${pkgs.wvkbd}/bin/wvkbd-mobintl --hidden -L 250";
      type = "daemon";
    };

    os.i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        settings.addons = {
          virtualkeyboardadapter.globalSection = {
            ActivateCmd = pkgs.writeShellScript "activate-osk" ''
              # Blacklist of non-real keyboard devices
              BLACKLIST="video-bus|power-button|huawei-wmi-hotkeys|at-translated-set-2-keyboard|hl-virtual-keyboard-.*|.*-consumer-control|.*-wireless-radio-control"
              
              if hyprctl devices -j | ${pkgs.jq}/bin/jq -e ".keyboards[] | select(.name | test(\"$BLACKLIST\") | not)" > /dev/null 2>&1; then
                  exit 0  # Real physical keyboard present, don't show OSK
              fi

              pkill -SIGUSR2 wvkbd-mobintl
            '';
            DeactivateCmd = "pkill -SIGUSR1 wvkbd-mobintl";
          };
        };
        addons = [
          pkgs.fcitx5-gtk
          inputs.fcitx-virtualkeyboard-adapter.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
  };
}
