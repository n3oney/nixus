{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  options.programs.ngrok.enable = lib.mkEnableOption "ngrok";

  config.hm = lib.mkIf config.programs.ngrok.enable {
    home.packages = [pkgs.ngrok];

    xdg.configFile."ngrok/ngrok.yml".source = hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix/ngrok";
  };
}
