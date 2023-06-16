{
  home = {pkgs, ...}: {
    home.packages = with pkgs; [
      horizontallyspinningrat

      obs-studio

      neofetch
      wl-clipboard
      cider
      gh
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

      # (factorio.override {
      #   releaseType = "alpha";
      #   experimental = true;
      # })
    ];
  };
}
