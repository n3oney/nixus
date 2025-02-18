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
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[cpp]" = {
          "editor.defaultFormatter" = "xaver.clang-format";
        };
        "clang-format.executable" = "${pkgs.clang-tools}/bin/clang-format";

        "command aliases" = {
          "workbench.action.files.save" = "w";
        };

        # "platformio-ide.customPATH" = "${pkgs.platformio}/bin/platformio";

        "editor.fontLigatures" = "'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss06', 'ss07', 'ss08', 'ss09', 'liga'";
        "git.enableSmartCommit" = true;
        "git.autofetch" = false;
        "git.confirmSync" = false;
        "editor.fontFamily" = "monospace";
        "editor.fontSize" = 15;
        "editor.formatOnSave" = true;
        "workbench.colorTheme" = "Rosé Pine Moon";
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
          bradlc.vscode-tailwindcss
          ms-vscode-remote.remote-containers
          bbenoist.nix
          rust-lang.rust-analyzer
        ])
        ++ (
          pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "tailwind-fold";
              publisher = "stivo";
              version = "0.2.0";
              sha256 = "sha256-yH3eA5jgBwxqnpFQkg91KQMkQps5iM1v783KQkQcWUU=";
            }
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
            # {
            # name = "platformio-ide";
            # publisher = "platformio";
            # version = "3.3.3";
            # sha256 = "sha256-pcWKBqtpU7DVpiT7UF6Zi+YUKknyjtXFEf5nL9+xuSo=";
            # }
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
