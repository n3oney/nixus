{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    wget
    libnotify
    ripgrep
  ];
}
