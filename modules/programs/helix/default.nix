{
  lib,
  pkgs,
  inputs,
  ...
}: {
  # inputs.helix.url = "github:helix-editor/helix";

  hm = {
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
      package = let
        # packages = inputs.helix.packages.${pkgs.system};
      in
        pkgs.helix;
      settings = {
        theme = "catppuccin_mocha";

        editor = {
          true-color = true;
          lsp = {
            display-inlay-hints = true;
          };

          rulers = [
            80
            100
            120
          ];

          cursor-shape = {
            insert = "bar";
          };

          indent-guides.render = true;
        };
      };

      languages = {
        language-server = {
          emmet-ls = {
            command = lib.getExe pkgs.emmet-language-server;
            args = ["--stdio"];
          };
          clangd.command = "${pkgs.llvmPackages.clang-unwrapped}/bin/clangd";
          typescript-language-server = {
            command = lib.getExe pkgs.nodePackages.typescript-language-server;
            args = ["--stdio"];
            config.hostInfo = "helix";
            config.documentFormatting = false;
            config.includeCompletionsForModuleExports = false;
          };
          rust-analyzer.command = lib.getExe pkgs.rust-analyzer;
          vscode-css-language-server = {
            command = "${pkgs.vscode-langservers-extracted}/bin/vscode-css-language-server";
            args = ["--stdio"];
            config.provideFormatter = true;
          };
          tailwindcss-ls = {
            command =
              lib.getExe pkgs.nodejs;
            args = ["${pkgs.vimPlugins.coc-tailwindcss}/lsp/tailwindcss-language-server/dist/index.js" "--stdio"];
            config = {};
          };
          nil = {
            command = lib.getExe pkgs.nil;
            config = {
              nix.flake.nixpkgsInputName = "nixpkgs";
            };
          };
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
            roots = ["flake.nix"];
          }
          (withLangServers (mkPrettier "typescript" "ts") ["typescript-language-server" "eslint" "emmet-ls"])
          (withLangServers (mkPrettier "tsx" "tsx") ["typescript-language-server" "eslint" "emmet-ls"])
          (withLangServers (mkPrettier "javascript" "js") ["typescript-language-server" "eslint" "emmet-ls"])
          (withLangServers (mkPrettier "jsx" "js") ["typescript-language-server" "eslint" "emmet-ls"])
          (mkPrettier "css" "css")
          (mkPrettier "scss" "scss")
          (mkPrettier "markdown" "md")
        ];
      };
    };
  };
}
