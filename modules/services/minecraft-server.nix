{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.minecraft-server.enable = lib.mkEnableOption "Minecraft Server";

  config = lib.mkIf config.services.minecraft-server.enable {
    impermanence.systemDirs = ["/var/lib/minecraft"];

    os = {
      services.minecraft-server = {
        package = pkgs.papermcServers.papermc-1_21_3;
        enable = true;
        eula = true;
        openFirewall = true;
        declarative = false;
      };

      networking.firewall.allowedUDPPorts = [25565];
    };
  };
}
