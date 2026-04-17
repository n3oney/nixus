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

      services.resolved.enable = true;
      networking.networkmanager.dns = "systemd-resolved";

      # Set Cloudflare as the system-wide upstream
      services.resolved = {
        fallbackDns = ["1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001"];
        dnssec = "false";
        domains = ["~."]; # route all otherwise-unmatched queries to the configured DNS

        settings = {
          Resolve = {
            DNS = "1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001";
            DNSStubListener = "yes";
          };
        };
      };
    };
    impermanence.systemDirs = ["/var/lib/tailscale"];
  };
}
