{
  lib,
  pkgs,
  inputs,
  ...
}: {
  inputs.helix.url = "github:helix-editor/helix";

  hm = {
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
      package = let
        packages = inputs.helix.packages.${pkgs.system};
      in
        packages.helix.passthru.wrapper (packages.helix-unwrapped.overrideAttrs (old: {
          patches =
            (old.patches or [])
            ++ [
              # doesnt apply for no reason idk y
              # (pkgs.fetchpatch {
              # url = "https://github.com/helix-editor/helix/pull/7474.diff";
              # hash = "sha256-iK9vfYFd6NiMjuhvUyyYA5sb+9bytdF+hTqurwnFk2Y=";
              # })
            ];
        }));
      settings = {
        theme = "catppuccin_macchiato";

        editor = {
          true-color = true;
          lsp = {
            display-inlay-hints = true;
          };

          cursor-shape = {
            insert = "bar";
          };

          indent-guides.render = true;
        };
      };

      languages = {
        language-server = {
          typst-lsp.command = "${pkgs.typst-lsp}/bin/typst-lsp";
          typescript-language-server = {
            command = lib.getExe pkgs.nodePackages.typescript-language-server;
            args = ["--stdio"];
            config.hostInfo = "helix";
            config.documentFormatting = false;
          };
          vscode-css-language-server = {
            command = lib.getExe pkgs.nodePackages.vscode-css-languageserver-bin;
            args = ["--stdio"];
            config.provideFormatter = true;
          };
          nil.command = lib.getExe pkgs.nil;
          eslint = {
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
            args = ["--stdio"];
            config = {
              validate = "on";
              experimental.useFlatConfig = false;
              rulesCustomizations = [];
              run = "onType";
              problems.shortenToSingleLine = false;
              nodePath = "";
              codeAction.disableRuleComment = {
                enable = true;
                location = "separateLine";
              };

              codeActionOnSave = {
                enable = true;
                mode = "fixAll";
              };

              workingDirectory.mode = "location";
            };
          };
        };
        language = let
          withLangServers = lang: servers:
            lang
            // {
              language-servers = (lang.language-servers or []) ++ servers;
            };
          mkPrettier = name: ext: {
            inherit name;
            auto-format = true;
            formatter = {
              command = "${pkgs.prettierd}/bin/prettierd";
              args = ["file.${ext}"];
            };
          };
        in [
          {
            name = "nix";
            auto-format = true;
            formatter = {command = lib.getExe pkgs.alejandra;};
          }
          (withLangServers (mkPrettier "typescript" "ts") ["typescript-language-server" "eslint"])
          (withLangServers (mkPrettier "tsx" "tsx") ["typescript-language-server" "eslint"])
          (withLangServers (mkPrettier "javascript" "js") ["typescript-language-server" "eslint"])
          (withLangServers (mkPrettier "jsx" "js") ["typescript-language-server" "eslint"])
          (mkPrettier "css" "css")
          (mkPrettier "scss" "scss")
          (mkPrettier "markdown" "md")
        ];
      };
    };
  };
}
