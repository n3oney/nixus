{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  # services.lemmy.enable = true;

  # services.conduit.enable = true;

  services.arr = {
    enable = true;
    bazarr.enable = false;
    jackett = {
      enable = true;
      caddy = false;
    };
    jellyfin.enable = false;
    plex.enable = false;
    radarr.enable = false;
    sonarr.enable = false;
    transmission.enable = false;
  };

  services.adguard.enable = true;

  services.smarthome.enable = true;

  services.shairport-sync.enable = true;

  services.mopidy.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
