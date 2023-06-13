{
  inputs = {
    agenix.url = "github:ryantm/agenix";
  };

  add = {agenix, ...}: {
    homeModules = [agenix.homeManagerModules.default];
  };

  home = {
    inputs,
    pkgs,
    ...
  }: {
    age.secrets.ha_assist_config.file = ../secrets/ha_assist_config.age;
    age.identityPaths = ["/home/neoney/.ssh/id_ed25519_agenix"];
    home.packages = [inputs.agenix.packages.${pkgs.system}.default];
  };
}
