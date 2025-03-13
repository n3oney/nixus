{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.rider.enable = lib.mkEnableOption "JetBrains Rider";

  config = lib.mkIf config.programs.rider.enable {
    hm.home.packages = [
      (pkgs.jetbrains.rider.overrideAttrs
        (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/rider \
                --suffix PATH : "${pkgs.nodejs_23}/bin"
            '';
        }))
      pkgs.dotnet-sdk_9
    ];

    hm.home.file.".ideavimrc".text = ''
      set clipboard^=unnamedplus
    '';

    impermanence.userDirs = [".java/.userPrefs" ".config/JetBrains" ".local/share/JetBrains" ".cache/JetBrains"];
  };
}
