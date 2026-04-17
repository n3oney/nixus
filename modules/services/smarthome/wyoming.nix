{
  config,
  lib,
  ...
}: {
  options.services.smarthome.wyoming.enable = lib.mkEnableOption "wyoming" // {default = config.services.smarthome.enable;};

  config.os = lib.mkIf config.services.smarthome.wyoming.enable {
    services.wyoming = {
      openwakeword = {
        uri = "tcp://0.0.0.0:10400";
        enable = true;
        extraArgs = ["--preload-model" "ok_nabu"];
      };
      piper.servers = {
        gosia = {
          uri = "tcp://0.0.0.0:10200";
          voice = "pl_PL-gosia-medium";
          enable = true;
        };
        lessac = {
          uri = "tcp://0.0.0.0:10201";
          voice = "en_US-lessac-medium";
          enable = true;
        };
      };
    };
  };
}
