{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
  
  # Lock command using physlock and hyprlock
  # We trigger unlock-session after hyprlock exits to fire the unlock_cmd
  # flags: --no-fade-in (disable fade in animation)
  # Note: physlock must use the setuid wrapper at /run/wrappers/bin/physlock
  lockScript = pkgs.writeShellScript "lock-script" ''
    /run/wrappers/bin/physlock -ldms && ${lib.getExe pkgs.hyprlock} --no-fade-in && ${pkgs.systemd}/bin/loginctl unlock-session
  '';

  # Suspend script with CPU check
  suspendScript = pkgs.writeShellScript "suspend-script" ''
    if [ "$(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r '.sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor')" -lt 80 ]; then
      systemctl suspend
    fi
  '';
in {
  config = mkIf cfg.enable {
    hm.services.hypridle = {
      enable = true;
      
      settings = {
        general = {
          lock_cmd = "${lockScript}";
          unlock_cmd = "/run/wrappers/bin/physlock -Ld";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 360; # 6min
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 420; # 7min
            on-timeout = "${suspendScript}";
          }
        ];
      };
    };
  };
}
