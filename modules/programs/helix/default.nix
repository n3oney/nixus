{
  lib,
  pkgs,
  hmConfig,
  ...
}: {
  os.nixpkgs.overlays = [
    (_: prev: {
      nil = prev.nil.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ../../../0001-nix.patch
          ];
      });
    })
  ];

  hm = {
    home.sessionVariables.EDITOR = "hx";

    programs.helix = {
      enable = true;
      package = pkgs.helix.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ./format-filename.patch
          ];
      });
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
        # future-proofing
        language-server = {
          typescript-language-server = {
            command = lib.getExe pkgs.nodePackages.typescript-language-server;
            args = ["--stdio"];
            config.hostInfo = "helix";
          };
          vscode-css-language-server = {
            command = lib.getExe pkgs.nodePackages.vscode-css-languageserver-bin;
            args = ["--stdio"];
            config.provideFormatter = true;
          };
          nil.command = lib.getExe pkgs.nil;
        };
        language = let
          mkPrettier = name: ext: {
            inherit name;
            auto-format = true;
            formatter = {
              command = pkgs.writeShellScript "prettierd.sh" ''
                ${pkgs.prettierd}/bin/prettierd "$1" 2>/dev/null

                ${pkgs.wakatime}/bin/wakatime-cli --entity "$1" --plugin "Helix/${hmConfig.programs.helix.package.version} Helix/${hmConfig.programs.helix.package.version}" --write --key $(cat "${hmConfig.age.secrets.wakatime.path}") --api-url https://wakapi.dev/api 2>&1 >/dev/null &
              '';
              args = ["{}"];
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
