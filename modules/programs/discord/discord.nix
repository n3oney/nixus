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

  config.os.nixpkgs.config.permittedInsecurePackages = mkIf cfg.enable [
    "armcord-3.2.4"
  ];

  config.hm = mkIf cfg.enable (let
    vencordConfig = cfg.vencordSettings;
  in {
    home.packages = with pkgs; [
      (runCommand "armcord-repro" {} ''
        mkdir $out
        ln -s ${armcord}/* $out
        rm $out/bin
        mkdir $out/bin
        for bin in ${armcord}/bin/*; do
         wrapped_bin=$out/bin/$(basename $bin)
         echo "#!${pkgs.bash}/bin/bash
           DBPATH=\"\''${XDG_CONFIG_HOME:-\$HOME/.config}/ArmCord/Local Storage/leveldb\" ${leveldb-cli}/bin/leveldb-cli put \"_https://canary.discord.com\0\x01VencordSettings\" \"\$(printf '\\001${lib.escape ["\""] (builtins.toJSON vencordConfig)}')\"
           exec $bin \$@
         " > $wrapped_bin
         chmod +x $wrapped_bin
        done
      '')
    ];

    xdg.configFile."ArmCord/storage/settings.json".text = builtins.toJSON cfg.armcordSettings;
  });
}
