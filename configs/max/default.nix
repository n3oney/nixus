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
      host = "jackett.max.local:80";
    };
    jellyfin.enable = false;
    radarr.enable = false;
    sonarr.enable = false;
    transmission.enable = false;
  };

  services.adguard = {
    enable = true;
    host = "adguard.max.local:80";
  };

  services.smarthome = {
    enable = true;
    home-assistant.host = "hass.max.local:80";
  };

  services.librespot.enable = true;

  services.mopidy.enable = false;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
