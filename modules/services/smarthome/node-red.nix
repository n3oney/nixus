{
  config,
  lib,
  ...
}: {
  options.services.smarthome.node-red.enable = lib.mkEnableOption "Node-RED" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.node-red.enable {
    services.node-red = {
      enable = true;
      openFirewall = true;
      withNpmAndGcc = true;
    };
  };
}
