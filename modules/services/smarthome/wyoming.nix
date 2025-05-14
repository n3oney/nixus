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
        preloadModels = ["ok_nabu"];
      };
      faster-whisper.servers.polish = {
        uri = "tcp://0.0.0.0:10300";
        model = "tiny-int8";
        language = "en";
        enable = true;
        extraArgs = [];
      };
    };
  };
}
