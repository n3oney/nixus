{pkgs, ...}: {
  users.main = "neoney";

  programs.btop.enable = true;

  services.lemmy.enable = true;

  services.conduit.enable = true;

  services.arr.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
    lazygit
  ];

  os.environment.systemPackages = [pkgs.wget];
}
