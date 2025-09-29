{
  lib,
  config,
  ...
}: {
  options.services.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.services.tailscale.enable {
    os = {
      services.tailscale.enable = true;
      networking.nameservers = lib.mkForce ["100.100.100.100" "1.1.1.1" "1.0.0.1"];
      networking.search = ["forest-piano.ts.net"];
    };
    impermanence.systemDirs = ["/var/lib/tailscale"];
  };
}
