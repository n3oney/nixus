{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  options.programs.orcaSlicer.enable = lib.mkEnableOption "Orca";

  config = lib.mkIf config.programs.orcaSlicer.enable (let
    wxShim = pkgs.wxGTK33 // {
      override = args: pkgs.wxGTK33.override (
        removeAttrs args ["withCurl" "withPrivateFonts" "withEGL"]
      );
    };
    orcaslicer = (inputs.orca-slicer-nightly.packages.${pkgs.stdenv.hostPlatform.system}.default.override {
      eigen = pkgs.eigen_5;
      wxwidgets_3_1 = wxShim;
    }).overrideAttrs (old: {
      version = "2.4.0-alpha";
      src = pkgs.fetchFromGitHub {
        owner = "OrcaSlicer";
        repo = "OrcaSlicer";
        rev = "v2.4.0-alpha";
        hash = "sha256-xhmmHtVsLn4d1Q577ZNXYPzwsBsScfecx4ckLpceJqU=";
        fetchSubmodules = true;
      };
      patches = builtins.filter (p:
        !(lib.hasInfix "pr-7650" (builtins.baseNameOf (toString p)))
      ) (old.patches or []);
    });
  in {
    impermanence.userDirs = [".config/OrcaSlicer" ".local/share/orca-slicer"];

    hm = {
      home.packages = [orcaslicer];
    };
  });
}
