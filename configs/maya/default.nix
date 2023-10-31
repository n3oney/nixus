{pkgs, ...}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;

  services.lemmy.enable = true;

  services.conduit.enable = true;

  services.minecraft-server.enable = true;

  services.arr = {
    enable = true;
    jackett.enable = false;
  };

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
