{
  # pkgs,
  # lib,
  # config,
  # inputs,
  ...
}: {
  # TODO: figure out shadower pipeline for niri screenshots
  # niri already has built-in window shadows, so shadower may be redundant
  # jaq also doesn't handle null chaining the same as jq (.ScreenshotCaptured.path // empty fails on other events)

  # shadowerPkg = inputs.shadower.packages.${pkgs.stdenv.hostPlatform.system}.shadower;
  # radius = builtins.floor cfg.niri.cornerRadius;

  # screenshotDaemon = pkgs.writeShellScriptBin "niri-screenshot-shadow" ''
  #   niri msg -j event-stream | while read -r line; do
  #     path=$(echo "$line" | ${pkgs.jaq}/bin/jaq -r '.ScreenshotCaptured.path // empty')
  #     if [ -n "$path" ] && [ -f "$path" ]; then
  #       ${shadowerPkg}/bin/shadower -r ${toString radius} < "$path" | ${pkgs.wl-clipboard}/bin/wl-copy -t image/png
  #       rm -f "$path"
  #     fi
  #   done
  # '';

  # hm.systemd.user.services.niri-screenshot-shadow = {
  #   Unit = {
  #     Description = "Niri screenshot shadow post-processor";
  #     PartOf = ["graphical-session.target"];
  #     After = ["graphical-session.target"];
  #   };
  #   Service = {
  #     ExecStart = "${screenshotDaemon}/bin/niri-screenshot-shadow";
  #     Restart = "on-failure";
  #     RestartSec = 3;
  #   };
  #   Install.WantedBy = ["graphical-session.target"];
  # };
}
