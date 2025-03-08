{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  programs.zoxide.enable = true;

  # services.conduit.enable = true;

  services.smarthome = {
    enable = true;
    home-assistant.host = "hass.max.local:80";
  };

  services.librespot.enable = true;

  #services.sage.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
