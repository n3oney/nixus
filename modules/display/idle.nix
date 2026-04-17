{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;

  # physlock must use the setuid wrapper at /run/wrappers/bin/physlock
  lockScript = pkgs.writeShellScript "lock-script" ''
    /run/wrappers/bin/physlock -ldms && ${lib.getExe pkgs.hyprlock} --no-fade-in && ${pkgs.systemd}/bin/loginctl unlock-session
  '';

  niri = "${hmConfig.programs.niri.package}/bin/niri";
  loginctl = "${pkgs.systemd}/bin/loginctl";

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
    hm.services.swayidle = {
      enable = true;

      events = [
        {
          event = "before-sleep";
          command = "${loginctl} lock-session";
        }
        {
          event = "after-resume";
          command = "${niri} msg action power-on-monitors";
        }
        {
          event = "lock";
          command = "${lockScript}";
        }
        {
          event = "unlock";
          command = "/run/wrappers/bin/physlock -Ld";
        }
      ];

      timeouts = [
        {
          timeout = 300; # 5min
          command = "${loginctl} lock-session";
        }
        {
          timeout = 360; # 6min
          command = "${niri} msg action power-off-monitors";
          resumeCommand = "${niri} msg action power-on-monitors";
        }
        {
          timeout = 420; # 7min
          command = "${suspendScript}";
        }
      ];
    };
  };
}
