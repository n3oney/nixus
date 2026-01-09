{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
in {
  config = mkIf cfg.enable {
    hm = {
      home.packages = with pkgs;
      with inputs.hyprcontrib.packages.${pkgs.system};
      with inputs.shadower.packages.${pkgs.system}; [
        inputs.hyprland-qtutils.packages.${pkgs.system}.hyprland-qtutils
        pulseaudio

        wl-clipboard

        (wlsunset.overrideAttrs (old: {
          src = fetchFromSourcehut {
            owner = "~kennylevinsen";
            repo = old.pname;
            rev = "81cfb0b4f8e44db9e5ecb36222a24d53a953e6aa";
            sha256 = "sha256-Lxuhsk4/5EHuKPkBbaRtCCQ/LFvIxyc+VQYEoaVT484=";
          };
        }))

        hyprpicker
        grimblast

        jaq
        shadower

        (writeShellScriptBin
          "pauseshot"
          ''
            pkill -9 hyprpicker # kill all hyprpicker instances before launching this - sometimes it lags out
            ${hyprpicker}/bin/hyprpicker -r -z &
            picker_proc=$!

            ${grimblast}/bin/grimblast save area -

            kill $picker_proc
          '')
      ];
    };
  };
}
