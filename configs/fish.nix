{
  system = _: {
    programs.fish.enable = true;
  };

  home = {
    pkgs,
    lib,
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
        # neovim wrapper to automatically disable transparency in foot
        # and re-enable it after closing it
        nvim = ''
          for a in 2 6 a d f ; printf "\033]11;rgba:1f/1f/28/ff\007" ; end

          /usr/bin/env nvim $argv

          for a in 2 6 a d f ; printf "\033]11;rgba:1f/1f/28/b2\007" ; end
        '';
        hd = ''
          sudo nix system apply ~/nixus $argv
        '';
      };
      shellAbbrs = {
        npm = "pnpm";
        cd = "z";
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
  };
}
