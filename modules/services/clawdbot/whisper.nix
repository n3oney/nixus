{
  config,
  lib,
  ...
}: {
  config.os = lib.mkIf config.services.clawdbot.enable {
    services.wyoming.faster-whisper.servers.clawdbot = {
      enable = true;
      model = "small";
      language = "auto";  # Auto-detect language (PL/EN/etc.)
      uri = "tcp://127.0.0.1:10301";
      device = "cpu";
    };
  };
}
