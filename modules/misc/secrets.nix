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
          (secretForHostnames ["max"] ../../secrets/z2m.age "z2m.yaml" {
            owner = "zigbee2mqtt";
            group = "zigbee2mqtt";
            mode = "770";
          })
          (
            secretForHostnames ["miko" "ciri" "yen"] ../../secrets/shibabot.age "shibabot" {owner = "shibabot";}
          )
        ];
        environment.systemPackages = [inputs.agenix.packages.${pkgs.system}.default];
      };

      hm = {
        age.secrets = lib.mkMerge [
          (secretForHostnames ["miko" "ciri"] ../../secrets/ha_assist_config.age "ha_assist_config" {})
          (secretForHostnames ["miko" "ciri"] ../../secrets/gh_notifications_key.age "gh_notifications_key" {})
          (secretForHostnames ["miko" "ciri" "yen" "max"] ../../secrets/ssh_hosts.age "ssh_hosts" {})
          (secretForHostnames ["miko" "ciri" "yen" "max"] ../../secrets/ngrok.age "ngrok" {})
          (secretForHostnames ["miko" "ciri"] ../../secrets/mcp.age "mcp" {})
        ];
        age.identityPaths = ["/home/neoney/.ssh/id_ed25519_agenix"];
      };
    })
  ];
}
