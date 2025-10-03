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
    ];

    hm = {
      programs.opencode = {
        package = pkgs.opencode.overrideAttrs (old: {
          version = "0.13.5";
          src = pkgs.fetchFromGitHub {
            owner = "sst";
            repo = "opencode";
            tag = "v0.13.5";
            hash = "sha256-GiByJg4NpllA4N4QGSyWsBNqKqKIdxicIjQpc7mHgEs=";
          };
          patches =
            old.patches
            ++ [
              (pkgs.fetchpatch {
                url = "http://github.com/sst/opencode/pull/2830.patch";
                sha256 = "sha256-adUMxWG4qA0Qmw7Zyo5KjNyCjTPbSbbvMb7XZcO7rjI=";
              })

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
          provider = {
            zaianthropic = {
              npm = "@ai-sdk/anthropic";
              name = "z.AI Claude Compat";
              options.baseURL = "https://api.z.ai/api/anthropic/v1";
              models = {
                "glm-4.5" = {
                  "id" = "glm-4.5";
                  "name" = "GLM-4.5";
                  "attachment" = false;
                  "reasoning" = true;
                  "temperature" = true;
                  "tool_call" = true;
                  "release_date" = "2025-07-28";
                  "cost" = {
                    "input" = 0.6;
                    "output" = 2.2;
                    "cache_read" = 0.11;
                    "cache_write" = 0;
                  };
                  limit = {
                    context = 131072;
                    output = 98304;
                  };
                };
              };
            };
          };
        };
        /*
          language_models = {
          anthropic = {
            api_url = "https://api.z.ai/api/anthropic";

            available_models = [
              {
                name = "glm-4.5";
                display_name = "GLM 4.5";
                max_tokens = 131072; #128k
                mode.type = "thinking";
              }
            ];
          };
        };
        */
      };
    };
  };
}
