{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.opencode.enable = lib.mkEnableOption "opencode";

  config = lib.mkIf config.programs.opencode.enable {
    impermanence.userDirs = [
      ".local/share/opencode"
      ".cache/opencode"
    ];

    hm = {
      programs.opencode = {
        package = pkgs.opencode.overrideAttrs (old: {
          /*
            version = "0.15.3";
          src = pkgs.fetchFromGitHub {
            owner = "sst";
            repo = "opencode";
            tag = "v0.15.3";
            hash = "sha256-zypzRF31610x2EaMCXDOLKb6oyEWDLGGLeQYG99vYGw=";
          };
          */
          patches =
            old.patches
            ++ [
              # (pkgs.fetchpatch {
              #   url = "http://github.com/sst/opencode/pull/2830.patch";
              #   sha256 = "sha256-adUMxWG4qA0Qmw7Zyo5KjNyCjTPbSbbvMb7XZcO7rjI=";
              # })

              (pkgs.fetchpatch {
                url = "http://github.com/sst/opencode/pull/2653.patch";
                sha256 = "sha256-9Pfz65ChM9dHZ2pXWCFGWcu1mpG+odBAJmNTeL5HAig=";
              })

              (pkgs.fetchpatch {
                url = "http://github.com/sst/opencode/pull/2867.patch";
                sha256 = "sha256-YaS58yqSUPQi8SUc3LLJAx+delaQIXhqG2LkKnIZBTo=";
              })
            ];
        });
        enable = true;
        settings = {
          theme = "opencode";
          instructions = [".github/copilot-instructions.md"];
        };
      };
    };
  };
}
