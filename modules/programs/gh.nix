{
  lib,
  config,
  hmConfig,
  ...
}: let
  cfg = config.programs.gh;
in {
  options.programs.gh.enable = lib.mkEnableOption "gh CLI with agenix-managed hosts.yml";

  config = lib.mkIf cfg.enable {
    hm = {
      programs.gh.enable = true;

      xdg.configFile."gh/hosts.yml".source =
        hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix/gh_token";

      age.secrets.gh_token.file = ../../secrets/gh_token.age;
    };
  };
}
