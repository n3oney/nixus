{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
in {
  config.hm = mkIf cfg.enable {
    home.packages = [
      pkgs.wl-clipboard
      pkgs.jaq
      (pkgs.writeShellScriptBin "jq" ''
        exec ${pkgs.jaq}/bin/jaq "$@"
      '')
    ];
  };
}
