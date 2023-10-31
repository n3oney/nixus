{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.minecraft-server.enable = lib.mkEnableOption "Minecraft Server";

  config.os.services.minecraft-server = lib.mkIf config.services.minecraft-server.enable {
    package = pkgs.papermc;
    enable = true;
    eula = true;
    whitelist = {
      neoney = "22c31a0b-3251-4fc4-a9ef-f0697d5735b0";
      xRirty = "4bcb8a8e-fd25-4824-b4a1-c587ce53ae1f";
    };
    openFirewall = true;
    serverProperties = {
      gamemode = 0;
      max-players = 2;
      white-list = true;
    };
    declarative = true;
  };
}
