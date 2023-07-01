{
  lib,
  pkgs,
  ...
}: {
  os.nixpkgs.overlays = [
    (_: prev: {
      nil = prev.nil.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ../../0001-nix.patch
          ];
      });
    })
  ];

  hm = {
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
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
        };
      };

      languages = {
        language = let
          mkPrettier = name: parser: {
            inherit name;
            auto-format = true;
            formatter = {
              command = lib.getExe pkgs.nodePackages.prettier;
              args = ["--parser" parser];
            };
          };
        in [
          {
            name = "nix";
            auto-format = true;
            formatter = {command = lib.getExe pkgs.alejandra;};
            language-server = {command = lib.getExe pkgs.nil;};
          }
          ((mkPrettier "typescript" "typescript")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "tsx" "typescript")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "javascript" "typescript")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "jsx" "typescript")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "css" "css")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.vscode-css-languageserver-bin;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "scss" "scss")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.vscode-css-languageserver-bin;
                args = ["--stdio"];
              };
            })
          (mkPrettier "markdown" "markdown")
        ];
      };
    };
  };
}
