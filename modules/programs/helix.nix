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

          indent-guides.render = true;
        };
      };

      languages = {
        language = let
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
            language-server = {command = lib.getExe pkgs.nil;};
          }
          ((mkPrettier "typescript" "ts")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "tsx" "tsx")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "javascript" "js")
            // {
              language-server = {
                command = lib.getExe pkgs.nodePackages.typescript-language-server;
                args = ["--stdio"];
              };
            })
          ((mkPrettier "jsx" "js")
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
          (mkPrettier "markdown" "md")
        ];
      };
    };
  };
}
