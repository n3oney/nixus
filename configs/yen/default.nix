{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  services.minecraft-server.enable = true;

  services.syncthing = {
    enable = true;
    openToInternet = true;
  };

  services.n8n.enable = true;

  services.degra-ical.enable = true;

  services.vaultwarden.enable = true;
  services.tailscale.enable = true;

  programs.zoxide.enable = true;

  h.packages = with pkgs; [
    ripgrep
  ];

  os.environment.systemPackages = [pkgs.wget];
}
