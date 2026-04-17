{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.display;
  inherit (lib) mkIf;
in {
  config.h = mkIf cfg.enable {
    packages = [
      pkgs.wl-clipboard
      pkgs.jaq
      (pkgs.writeShellScriptBin "jq" ''
        exec ${pkgs.jaq}/bin/jaq "$@"
      '')
    ];
  };
}
