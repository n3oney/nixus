{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  background = "#${config.colors.colorScheme.palette.base00}${toHexString (floor (config.colors.backgroundAlpha * 255))}";
in {
  hm = lib.mkIf config.programs.discord.enable {
    xdg.configFile."vesktop/themes/Catppuccin.theme.css".text = ''
      /**
       * @name Catppuccin
       * @author Catppuccin team and n3oney
       * @version 1.0.0
       */


      @import url("https://catppuccin.github.io/discord/dist/catppuccin-macchiato-pink.theme.css");

      #app-mount{
        background-color: transparent;
        border-color: transparent;
      }

      body,
      .bg__12180,
      .scrollableContainer__33e06,
      .container__590e2,
      .panels__58331,
      .container_ca50b9,
      .chat__52833,
      .container_b2ce9c,
      .chatContent__5dca8,
      .member_aa4760 {
          background: transparent !important
      }

      .app_de4237 {
          background: ${background} !important;
      }

      .guilds__2b93a,
      .sidebar_ded4b5,
      section[class^=title],
      .channelTextArea__2e60f,
      .members__9f47b {
          background: rgba(0, 0, 0, 0.1) !important;
      }

      form::before,
      .children__32014::after {
          background: unset !important;
      }
    '';
  };
}
