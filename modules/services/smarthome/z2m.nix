{
  config,
  lib,
  osConfig,
  ...
}: {
  options.services.smarthome.z2m.enable = lib.mkEnableOption "zigbee2mqtt" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.z2m.enable {
    networking.firewall.allowedTCPPorts = [8080];

    services.zigbee2mqtt = {
      enable = true;
      settings = {
        serial = {
          port = "/dev/ttyUSB0";
          adapter = "ember";
        };
        permit_join = false;
        homeassistant.enabled = true;
        frontend.enabled = true;

        mqtt = {
          server = "mqtt://localhost:1883";
          reject_unauthorized = true;
          user = "!${osConfig.age.secrets."z2m.yaml".path} user";
          password = "!${osConfig.age.secrets."z2m.yaml".path} password";
        };
      };
    };
  };
}
