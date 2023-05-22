{
  config,
  lib,
  ...
}:
with lib;
with builtins; {
  xdg.configFile."WebCord/Themes/transparency".text = ''
    body{
        background-color: transparent;
    }

    #app-mount{
        background-color: transparent;
        border-color: transparent;
    }

    .container-2o3qEW, .chat-2ZfjoI, .bg-1QIAus, .app-2CXKsg, .member-2gU6Ar, .sidebar-1tnWFu {
        background: transparent !important;
    }

    .members-3WRCEx, .container-1NXEtd, .guilds-2JjMmN, .chatContent-3KubbW  {
        background: #${config.programs.foot.settings.colors.background}${toHexString (floor (config.programs.foot.settings.colors.alpha * 255))} !important;
    }

    .container-1NXEtd {
      border-right: 1px solid #3d3f45;
      border-left: 1px solid #3d3f45;
    }
  '';
}
