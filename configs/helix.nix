{
  home = {
    lib,
    pkgs,
    inputs,
    ...
  }: {
    programs.helix = {
      enable = true;
      settings = {
        theme = "catppuccin_macchiato";

        editor = {
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
          (mkPrettier "typescript" "typescript")
          (mkPrettier "tsx" "typescript")
          (mkPrettier "javascript" "typescript")
        ];
      };
    };
  };
}