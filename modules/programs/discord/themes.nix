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
      .bg__960e4,
      .scrollableContainer__74017,
      .container__2637a,
      .panels__58331,
      .container_ca50b9,
      .chat_f75fb0,
      .container_c8ffbb,
      .chatContent_f75fb0,
      .app__160d8,
      .guilds_c48ade>ul,
      .container__37e49,
      .form_f75fb0,
      .member_c8ffbb,
      .floatingBars__74017,
      .panels_c48ade,
      .footer__214dc {
          background: transparent !important
      }

      .app_a3002d {
          background: ${background} !important;
      }

      .guilds_c48ade,
      .sidebar_c48ade,
      section[class^=title],
      .channelTextArea_f75fb0,
      .members_c8ffbb {
          background: rgba(0, 0, 0, 0.1) !important;
      }

      form::before,
      .children__9293f::after {
          background: unset !important;
      }
    '';
  };
}
