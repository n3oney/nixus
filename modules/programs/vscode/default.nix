{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.vscode.enable = lib.mkEnableOption "vscode";

  config.hm = lib.mkIf config.programs.vscode.enable {
    programs.vscode = {
      enable = true;
      userSettings = {
        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[jsonc]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "command aliases" = {
          "workbench.action.files.save" = "w";
        };
        "platformio-ide.customPATH" = "${pkgs.platformio}/bin/platformio";

        "git.enableSmartCommit" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "editor.fontFamily" = "monospace";
        "editor.fontSize" = 15;
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Rosé Pine";
      };

      extensions =
        (with pkgs.vscode-extensions; [
          mvllow.rose-pine
          mkhl.direnv
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint
          usernamehw.errorlens
          gruntfuggly.todo-tree
          eamodio.gitlens
          github.vscode-github-actions
          ms-vscode.cpptools-extension-pack
        ])
        ++ (
          pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "dancehelix";
              publisher = "silverquark";
              version = "0.5.16";
              sha256 = "sha256-oHwtlbB18ctEnfStDOpJ+2/Kq41JZog8FVhTa1/s7m0=";
            }
            {
              name = "command-alias";
              publisher = "ArturoDent";
              version = "0.6.2";
              sha256 = "sha256-NSDhmbCH1zHyLheOpd9Zr+gQZZAf7FN/89qXYeByw1U=";
            }
            {
              name = "platformio-ide";
              publisher = "platformio";
              version = "3.3.3";
              sha256 = "sha256-pcWKBqtpU7DVpiT7UF6Zi+YUKknyjtXFEf5nL9+xuSo=";
            }
          ]
        );
    };
  };
}
