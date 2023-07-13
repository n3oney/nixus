{
  config,
  osConfig,
  lib,
  inputs,
  pkgs,
  ...
}: let
  secretForHostnames = hostnames: secretFile: secretName:
    lib.mkIf (builtins.elem osConfig.networking.hostName hostnames) {
      ${secretName}.file = secretFile;
    };
in {
  options.agenix.enable = lib.mkEnableOption "agenix";

  config = lib.mkMerge [
    {
      inputs = {
        agenix.url = "github:ryantm/agenix";
      };
    }
    (lib.mkIf config.agenix.enable {
      osModules = [inputs.agenix.nixosModules.default];
      hmModules = [inputs.agenix.homeManagerModules.default];

      os = {
        age.secrets = lib.mkMerge [
          (secretForHostnames ["maya"] ../../secrets/sliding_sync_secret.age "sliding_sync_secret")
        ];
        environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];
      };

      hm = {
        age.secrets = lib.mkMerge [
          (secretForHostnames ["miko" "vic"] ../../secrets/ha_assist_config.age "ha_assist_config")
          (secretForHostnames ["miko" "vic"] ../../secrets/gh_notifications_key.age "gh_notifications_key")
          (secretForHostnames ["miko" "vic" "maya"] ../../secrets/wakatime.age "wakatime")
        ];
        age.identityPaths = ["/home/neoney/.ssh/id_ed25519_agenix"];
      };
    })
  ];
}
