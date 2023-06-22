{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  options.agenix.enable = lib.mkEnableOption "agenix";

  config = lib.mkMerge [
    {
      inputs = {
        agenix.url = "github:ryantm/agenix";
      };
    }
    (lib.mkIf config.agenix.enable {
      hmModules = [inputs.agenix.homeManagerModules.default];

      hm = {
        age.secrets.ha_assist_config.file = ../../secrets/ha_assist_config.age;
        age.secrets.gh_notifications_key.file = ../../secrets/gh_notifications_key.age;
        age.identityPaths = ["/home/neoney/.ssh/id_ed25519_agenix"];
        home.packages = [inputs.agenix.packages.${pkgs.system}.default];
      };
    })
  ];
}
