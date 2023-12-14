{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  options.programs.ags = {
    enable = lib.mkEnableOption "ags";
  };

  config.inputs.ags.url = "github:Aylur/ags";

  config.hmModules = [inputs.ags.homeManagerModules.default];

  config.hm = lib.mkIf config.programs.ags.enable {
    programs.ags = {
      enable = true;

      # configDir = ./config;

      extraPackages = [pkgs.libsoup_3];
    };
  };
}
