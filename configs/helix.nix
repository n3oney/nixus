{
  home = {
    lib,
    pkgs,
    inputs,
    ...
  }: {
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
              command = "prettier";
              args = ["--parser ${parser}"];
            };
          };
        in [
          {
            name = "nix";
            auto-format = true;
            formatter = {command = "alejandra";};
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
        ];
      };
    };
  };
}
