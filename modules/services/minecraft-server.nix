{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.minecraft-server.enable = lib.mkEnableOption "Minecraft Server";

  config.os.services.minecraft-server = lib.mkIf config.services.minecraft-server.enable {
    package = pkgs.papermcServers.papermc-1_21_3;
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = false;
  };
}
