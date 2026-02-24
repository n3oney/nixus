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
  # 10 Mbps in bytes/sec
  netThreshold = 1250000;

  suspendScript = pkgs.writeShellScript "suspend-script" ''
    cpu=$(${pkgs.sysstat}/bin/mpstat -o JSON 1 1 | ${lib.getExe pkgs.jaq} -r '.sysstat.hosts[0].statistics[0]["cpu-load"][0].usr | floor')

    # Sum rx_bytes across all non-lo interfaces, wait 1s, compare
    get_rx() {
      local total=0
      for f in /sys/class/net/*/statistics/rx_bytes; do
        iface=$(echo "$f" | cut -d/ -f5)
        [ "$iface" = "lo" ] && continue
        total=$((total + $(cat "$f")))
      done
      echo "$total"
    }

    rx1=$(get_rx)
    sleep 1
    rx2=$(get_rx)
    net_bps=$((rx2 - rx1))

    if [ "$cpu" -lt 80 ] && [ "$net_bps" -lt ${toString netThreshold} ]; then
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
