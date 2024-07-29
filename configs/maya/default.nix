{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  services.conduit.enable = true;

  services.mattermost.enable = true;

  services.minecraft-server.enable = true;

  services.uonetplan.enable = true;

  services.arr = {
    enable = true;
    jackett.enable = false;
  };

  services.shibabot.enable = true;

  services.vaultwarden.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
