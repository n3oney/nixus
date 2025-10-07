{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.datagrip.enable = lib.mkEnableOption "DataGrip";

  config = lib.mkIf config.programs.datagrip.enable {
    hm.home.packages = [
      (
        (pkgs.jetbrains.datagrip.override {jdk = pkgs.openjdk21;})
        /*
                                                                     .overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/webstorm \
                --suffix PATH : "${pkgs.nodejs_24}/bin"
            '';
        })
        */
      )
    ];

    impermanence.userDirs = [".java/.userPrefs" ".config/JetBrains" ".local/share/JetBrains" ".cache/JetBrains"];
  };
}
