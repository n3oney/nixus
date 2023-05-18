{
  home = {pkgs, ...}: {
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

      (writeShellScriptBin "x-terminal-emulator" ''
        exec foot
      '')

      (factorio.override {
        releaseType = "alpha";
        experimental = true;
      })
    ];
  };
}
