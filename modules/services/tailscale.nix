{
  lib,
  config,
  ...
}: {
  options.services.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.services.tailscale.enable {
    os = {
      services.tailscale.enable = true;
      # networking.nameservers = lib.mkForce ["100.100.100.100" "1.1.1.1" "1.0.0.1"];
      # networking.search = ["forest-piano.ts.net"];
      networking.firewall.allowedUDPPorts = [41641];

      services.resolved = {
        enable = true;
        settings.Resolve = {
          DNS = "1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001";
          DNSStubListener = "yes";
          FallbackDNS = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
          DNSSEC = "false";
          Domains = ["~."]; # route all otherwise-unmatched queries to the configured DNS
        };
      };
      networking.networkmanager.dns = "systemd-resolved";
    };
    impermanence.systemDirs = ["/var/lib/tailscale"];
  };
}
