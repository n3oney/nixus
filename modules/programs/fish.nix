{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  options.rebuildCommand = lib.mkOption {
    default = "nh os switch $argv";
    type = lib.types.str;
  };

  config = {
    impermanence.userFiles = [".local/share/fish/fish_history"];
    os = {
      programs.fish.enable = true;

      # users.defaultUserShell = pkgs.fish;
    };

    hm = {
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          if test "$TERM" != "dumb"  -a \( -z "$INSIDE_EMACS"  -o "$INSIDE_EMACS" = "vterm" \)
            eval (${lib.getExe pkgs.starship} init fish)
          end

          enable_transience
        '';
        functions = let
          # make terminal opaque while the command is running, and transparent after it stops
          opaquewrap = binary:
            with builtins;
            with lib; ''
              printf "\033]11;rgba:${
                concatStringsSep "/" (match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" config.colors.colorScheme.palette.base00)
              }/ff\007"

              ${binary} $argv

              printf "\033]11;rgba:${
                concatStringsSep "/" (match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" config.colors.colorScheme.palette.base00)
              }/${toHexString (floor (config.colors.backgroundAlpha * 255))}\007"
            '';
          inherit (lib) mkIf;
        in {
          nvim =
            mkIf (hmConfig.programs.neovim-flake or {enable = false;}).enable (opaquewrap "command nvim");
          hx =
            mkIf (hmConfig.programs.helix or {enable = false;}).enable (opaquewrap "command hx");
          btop =
            mkIf (hmConfig.programs.btop or {enable = false;}).enable (opaquewrap "command btop");

          hd = config.rebuildCommand;
        };
        shellAbbrs = {
          cd = "z";
        };

        shellAliases = {
          cat = "${pkgs.bat}/bin/bat";
        };
      };

      programs.direnv = {
        enable = true;
        nix-direnv = {
          enable = true;
          # package = pkgs.nix-direnv.override {
          # nix = pkgs.nix-super;
          # };
        };
      };

      programs.eza = {
        enable = true;
        # enableAliases = false;
        enableNushellIntegration = lib.mkForce false;
        icons = "auto";
        git = true;
      };
    };
  };
}
