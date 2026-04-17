{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.gh;
  yamlFormat = pkgs.formats.yaml {};
in {
  options.programs.gh.enable = lib.mkEnableOption "gh CLI with agenix-managed hosts.yml";

  config.h = lib.mkIf cfg.enable {
    packages = [pkgs.gh];

    xdg.config.files = {
      "gh/config.yml" = {
        generator = yamlFormat.generate "gh-config.yml";
        value = {
          aliases = {};
          editor = "";
          git_protocol = "https";
          version = "1";
        };
      };

      "gh/hosts.yml".source = "/run/user/1000/agenix/gh_token";
    };
  };
}
