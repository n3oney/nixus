{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.discord;
  inherit (lib) mkEnableOption mkIf;
in {
  options.programs.discord.enable = mkEnableOption "discord";

  config.hm = mkIf cfg.enable (let
    vencordConfig = cfg.vencordSettings;
  in {
    home.packages = with pkgs; [
      (runCommand "webcord-vencord-repro" {} ''
        mkdir $out
        ln -s ${webcord-vencord}/* $out
        rm $out/bin
        mkdir $out/bin
        for bin in ${webcord-vencord}/bin/*; do
         wrapped_bin=$out/bin/$(basename $bin)
         echo "#!${pkgs.bash}/bin/bash
           # DBPATH=\"\''${XDG_CONFIG_HOME:-\$HOME/.config}/WebCord/Local Storage/leveldb\" ${leveldb-cli}/bin/leveldb-cli put \"_https://discord.com\0\x01VencordSettings\" \"\$(printf '\\001${lib.escape ["\""] (builtins.toJSON vencordConfig)}')\"
           exec $bin \$@
         " > $wrapped_bin
         chmod +x $wrapped_bin
        done
      '')
    ];
  });
}
