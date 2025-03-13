{
  lib,
  config,
  pkgs,
  ...
}: {
  options.programs.webstorm.enable = lib.mkEnableOption "WebStorm";

  config = lib.mkIf config.programs.webstorm.enable {
    hm.home.packages = [
      (pkgs.jetbrains.webstorm.overrideAttrs (old: {
        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram $out/bin/rider \
              --suffix PATH : "${pkgs.nodejs_23}/bin"
          '';
      }))
    ];

    hm.home.file.".ideavimrc".text = ''
      set clipboard^=unnamedplus
    '';

    impermanence.userDirs = [".java/.userPrefs" ".config/JetBrains" ".local/share/JetBrains" ".cache/JetBrains"];
  };
}
