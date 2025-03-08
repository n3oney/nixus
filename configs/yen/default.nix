{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  services.conduit.enable = true;

  services.minecraft-server.enable = true;

  services.arr = {
    enable = false;
    jackett.enable = false;
  };

  services.syncthing = {
    enable = true;
    openToInternet = true;
  };

  services.shibabot.enable = true;

  services.vaultwarden.enable = true;

  programs.zoxide.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
