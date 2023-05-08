{
  pkgs,
  inputs,
  ...
}: {
  home.username = "neoney";
  home.homeDirectory = "/home/neoney";

  home.packages = with pkgs; [
    neofetch
    wl-clipboard
    cider
    pavucontrol
    xdragon

    nodejs
    nodePackages_latest.pnpm

    telegram-desktop

    lazygit

    xdg-utils
  ];

  programs.git = {
    enable = true;
    userName = "n3oney";
    userEmail = "neo@neoney.dev";
  };

  imports = [
    inputs.hyprland.homeManagerModules.default
    inputs.neovim-flake.homeManagerModules.default
    ./hyprland.nix
    ./neovim.nix
    ./foot.nix
    ./fish.nix
    ./starship.nix
    ./anyrun.nix
    ./discord
    ./firefox.nix
    ./eww
    ./gpg.nix
    ./gtk.nix
    ./keyring.nix
    ./nheko.nix
    ./notifications.nix
  ];

  home.sessionVariables = {
    XDG_CONFIG_HOME = "$HOME/.config";
  };

  home.stateVersion = "22.11";
  programs.home-manager.enable = true;
}
