{
  config,
  lib,
  ...
}:
with lib;
with builtins; let
  background = "#${config.programs.foot.settings.colors.background}${toHexString (floor (config.programs.foot.settings.colors.alpha * 255))}";
in {
  xdg.configFile."WebCord/Themes/transparency".text = ''
    @import url("https://catppuccin.github.io/discord/dist/catppuccin-macchiato-pink.theme.css");

    #app-mount{
      background-color: transparent;
      border-color: transparent;
    }

    body, .container-2o3qEW, .chat-2ZfjoI, .bg-1QIAus, .app-2CXKsg, .member-2gU6Ar, .sidebar-1tnWFu, .container-YkUktl, .scroller-WSmht3, .container-1oAagU, .scrollableContainer-15eg7h {
      background: transparent !important;
    }

    .members-3WRCEx, .container-1NXEtd, .guilds-2JjMmN, .chatContent-3KubbW, .title-31SJ6t, .panels-3wFtMD, .privateChannels-oVe7HL, .searchBar-3TnChZ, .container-2cd8Mz, .nowPlayingColumn-1eCBCN, .itemCard-3Etziu, .container-ZMc96U, .searchBar-2aylmZ, .channelTextArea-1FufC0 {
      background: ${background} !important;
    }

    .form-3gdLxP::before {
      opacity: 0;
    };


    .container-1NXEtd {
      border-right: 1px solid #3d3f45 !important;
      border-left: 1px solid #3d3f45 !important;
    }
  '';
}
