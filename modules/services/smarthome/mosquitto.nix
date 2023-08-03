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
            hashedPassword = "$7$101$TQrUXba2xQwEgcC0$i/LqAtjHl8Dw1Rhnbl+dDvHQWlBrgKL9+X0LENlof4c6UiY3QN4QV/3IRCLMj137Hm4wWddXEuZecyrLpKJM6w==";
          };
        }
      ];
    };
  };
}
