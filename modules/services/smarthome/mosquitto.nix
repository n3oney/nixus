{
  config,
  lib,
  ...
}: {
  options.services.smarthome.mosquitto.enable = lib.mkEnableOption "mosquitto" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.mosquitto.enable {
    networking.firewall.allowedTCPPorts = [1883];

    services.mosquitto = {
      enable = true;

      listeners = [
        {
          settings.allow_anonymous = false;
          users.neoney = {
            acl = ["readwrite #"];
            hashedPassword = "$7$101$imEmDk/nVR25q/yy$OtUGfAWVZI7L8yTXE65mssJ+tBh1HSfiYxmiQi1bWR7QjwcnJ2IUy43KSGEDWE6a21xTLm+Gar3x3qw5DTM0CA==";
          };
        }
      ];
    };
  };
}
