{
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}: let
  pivo = inputs.pivo.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # pivo reads SOUL.md (its base system prompt) relative to the working
  # directory, so give it a clean cwd holding just that file — keeps the
  # source tree's .env out of the picture (env comes from systemd instead).
  workdir = pkgs.runCommand "pivo-workdir" {} ''
    mkdir -p $out
    cp ${inputs.pivo}/SOUL.md $out/SOUL.md
  '';
in {
  options.services.smarthome.pivo.enable = lib.mkEnableOption "pivo voice assistant";

  config.os = lib.mkIf config.services.smarthome.pivo.enable {
    systemd.services.pivo = {
      description = "pivo - pi-agent-core voice assistant";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      path = [pkgs.ffmpeg pkgs.numbat];

      environment = {
        OPENAI_API_KEY = ":)";
        OPENAI_BASE_URL = "http://endurance:11434/v1";
        OPENAI_MODEL = "Bielik-11B-v3.0-Instruct.Q5_K_M.gguf";
        HASS_URL = "https://home-assistant.neoney.dev";
        WYOMING_HOST = "endurance";
        WYOMING_PORT_PL = "10200";
        OMNIVOICE_BASE_URL = "http://endurance:11436";
        WHISPER_HOST = "endurance";
      };

      serviceConfig = {
        ExecStart = "${pivo}/bin/pivo";
        WorkingDirectory = workdir;
        EnvironmentFile = osConfig.age.secrets.pivo.path;
        DynamicUser = true;
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    networking.firewall.allowedTCPPorts = [10500];
  };
}
