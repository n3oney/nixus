{
  lib,
  pkgs,
  ...
}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      if test "$TERM" != "dumb"  -a \( -z "$INSIDE_EMACS"  -o "$INSIDE_EMACS" = "vterm" \)
        eval (${lib.getExe pkgs.starship} init fish)
      end

      enable_transience
    '';
    functions = {
      # neovim wrapper to automatically disable transparency in alacritty and wezterm
      # and re-enable it after closing it
      nvim = ''
        if test $TERM = "alacritty"
            alacritty msg config window.opacity=1
          else
            printf "\033]1337;SetUserVar=%s=%s\007" nvim_open (echo -n yes | base64)
          end

          /usr/bin/env nvim $argv

          if test $TERM = "alacritty"
            alacritty msg config window.opacity=0.7
          else
            printf "\033]1337;SetUserVar=%s=%s\007" nvim_open (echo -n no | base64)
          end
      '';
      hd = ''
        sudo nixos-rebuild switch --flake ~/nixus $argv
      '';
    };
    shellAbbrs = {
      npm = "pnpm";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
