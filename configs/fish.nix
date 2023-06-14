{
  system = {pkgs, ...}: {
    programs.fish.enable = true;

    users.users.neoney.shell = pkgs.fish;
  };

  home = {
    pkgs,
    lib,
    config,
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
      functions =
        if config.programs.foot.enable
        then let
          # make terminal opaque while the command is running, and transparent after it stops
          opaquewrap = binary:
            with builtins;
            with lib; ''
              printf "\033]11;rgba:24/27/3a/ff\007"

              ${binary} $argv

              printf "\033]11;rgba:${
                concatStringsSep "/" (match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" config.programs.foot.settings.colors.background)
              }/${toHexString (floor (config.programs.foot.settings.colors.alpha * 255))}\007"
            '';
        in {
          nvim =
            if config.programs.neovim-flake.enable
            then opaquewrap "command nvim"
            else null;
          hx =
            if config.programs.helix.enable
            then opaquewrap "command hx"
            else null;
          btop =
            if config.programs.btop.enable
            then opaquewrap "command btop"
            else null;
        }
        else
          {}
          // {
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

    programs.exa = {
      enable = true;
      enableAliases = true;
      icons = true;
      git = true;
    };
  };
}
