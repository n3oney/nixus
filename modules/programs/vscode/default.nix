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
        "[cpp]" = {
          "editor.defaultFormatter" = "xaver.clang-format";
        };
        "clang-format.executable" = "${pkgs.clang-tools}/bin/clang-format";

        "command aliases" = {
          "workbench.action.files.save" = "w";
        };

        "platformio-ide.customPATH" = "${pkgs.platformio}/bin/platformio";

        "git.enableSmartCommit" = true;
        "git.autofetch" = false;
        "git.confirmSync" = false;
        "editor.fontFamily" = "monospace";
        "editor.fontSize" = 15;
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Rosé Pine";
        "git.openRepositoryInParentFolders" = "always";
        "security.workspace.trust.enabled" = false;
        "typescript.inlayHints.parameterNames.enabled" = "all";

        "extensions.experimental.affinity" = {
          "jasew.vscode-helix-emulation" = 1;
        };
      };

      extensions = with pkgs;
        (with vscode-extensions; [
          mvllow.rose-pine
          mkhl.direnv
          esbenp.prettier-vscode
          dbaeumer.vscode-eslint
          usernamehw.errorlens
          gruntfuggly.todo-tree
          eamodio.gitlens
          github.vscode-github-actions
          xaver.clang-format
          editorconfig.editorconfig
        ])
        ++ (
          pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "sqltools";
              publisher = "mtxr";
              version = "0.28.3";
              sha256 = "sha256-bTrHAhj8uwzRIImziKsOizZf8+k3t+VrkOeZrFx7SH8=";
            }
            {
              name = "vsliveshare";
              publisher = "MS-vsliveshare";
              version = "1.0.5932";
              sha256 = "sha256-uqBUGGvEIBP+ZpJqdAdTlnN65mJvW1SEWgjw8inBHW4=";
            }
            {
              name = "vscode-helix-emulation";
              publisher = "jasew";
              version = "0.6.2";
              sha256 = "sha256-V/7Tu1Ze/CYRmtxwU2+cQLOxLwH7YRYYeHSUGbGTb5I=";
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
            {
              name = "vscode-monorepo-workspace";
              publisher = "folke";
              version = "1.3.1";
              sha256 = "sha256-BtJBd9T+5qPY2YD93Rn2AiClwYGD1s4o+IEUHdaq61c=";
            }
            {
              name = "pretty-ts-errors";
              publisher = "yoavbls";
              version = "0.5.4";
              sha256 = "sha256-SMEqbpKYNck23zgULsdnsw4PS20XMPUpJ5kYh1fpd14=";
            }
          ]
        );
    };
  };
}
