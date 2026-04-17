{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.ngrok.enable = lib.mkEnableOption "ngrok";

  config.h = lib.mkIf config.programs.ngrok.enable {
    packages = [pkgs.ngrok];

    xdg.config.files."ngrok/ngrok.yml".source = "/run/user/1000/agenix/ngrok";
  };
}
