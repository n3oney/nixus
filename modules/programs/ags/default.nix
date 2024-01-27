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

  config.hmModules = [inputs.ags.homeManagerModules.default];

  config.hm = lib.mkIf config.programs.ags.enable {
    programs.ags = let
      agsPathPackages = [pkgs.sassc pkgs.wlroots.examples pkgs.bash pkgs.procps pkgs.findutils pkgs.xdg-utils];
    in {
      enable = true;

      package = inputs.ags.packages.${pkgs.system}.default.overrideAttrs (_: {
        postFixup = ''
          wrapProgram $out/bin/ags \
            --prefix PATH : "${builtins.concatStringsSep ":" (builtins.map (v: "${v}/bin") agsPathPackages)}"
        '';
      });

      # configDir = ./config;

      extraPackages = [pkgs.libsoup_3];
    };

    xdg.configFile."ags" = {
      source = ./config;
      recursive = true;
    };
  };
}
