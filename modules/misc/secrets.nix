{
  config,
  osConfig,
  lib,
  inputs,
  pkgs,
  ...
}: let
  secretForHostnames = hostnames: secretFile: secretName: extra:
    lib.mkIf (builtins.elem osConfig.networking.hostName hostnames) {
      ${secretName} =
        {
          file = secretFile;
        }
        // extra;
    };
in {
  options.agenix.enable = lib.mkEnableOption "agenix";

  config = lib.mkMerge [
    (lib.mkIf config.agenix.enable {
      osModules = [inputs.agenix.nixosModules.default];
      hmModules = [inputs.agenix.homeManagerModules.default];

      os = {
        age.secrets = lib.mkMerge [
          (secretForHostnames ["max"] ../../secrets/cloudflared.age "cloudflared" {
            owner = "cloudflared";
          })
          (secretForHostnames ["miko" "vic"] ../../secrets/wg.age "wg" {
            })
          (
            secretForHostnames [
              "miko"
              "vic"
              "maya"
            ]
            ../../secrets/uonetplan.age
            "uonetplan"
            {
              owner = "uonetplan";
            }
          )
        ];
        environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];
      };

      hm = {
        age.secrets = lib.mkMerge [
          (secretForHostnames ["miko" "vic"] ../../secrets/ha_assist_config.age "ha_assist_config" {})
          (secretForHostnames ["miko" "vic"] ../../secrets/gh_notifications_key.age "gh_notifications_key" {})
          (secretForHostnames ["miko" "vic" "maya" "max"] ../../secrets/wakatime.age "wakatime" {})
          (secretForHostnames ["miko" "vic" "maya" "max"] ../../secrets/ssh_hosts.age "ssh_hosts" {})
          (secretForHostnames ["miko" "vic" "maya" "max"] ../../secrets/ngrok.age "ngrok" {})
        ];
        age.identityPaths = ["/home/neoney/.ssh/id_ed25519_agenix"];
      };
    })
  ];
}
