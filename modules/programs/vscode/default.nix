{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.vscode.enable = lib.mkEnableOption "vscode";

  config = lib.mkIf config.programs.vscode.enable {
    impermanence.userDirs = [".config/Code/User/History" ".config/Code/User/workspaceStorage" ".config/Code/User/globalStorage" ".config/Code/WebStorage" ".config/Code/logs" ".config/Code/blob_storage" ".config/Code/Cache" ".config/Code/Code Cache" ".config/Code/CachedData" ".config/Code/CachedExtensionVSIXs" ".config/Code/CachedProfilesData" ".config/Code/Cookies" ".config/Code/Cookies-journal"];
    impermanence.userFiles = [".vscode/argv.json" ".config/Code/Network Persistent State" ".config/Code/TransportSecurity" ".config/Code/SharedStorage" ".config/Code/SharedStorage-wal" ".config/Code/Trust Tokens" ".config/Code/Trust Tokens-journal"];

    hm = {
      programs.vscode = {
        package = pkgs.vscode.overrideAttrs (old: {
          postFixup =
            (old.postFixup or "")
            + ''
              wrapProgram $out/bin/code --add-flags "--password-store='gnome-libsecret'"
            '';
        });
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
          "editor.fontLigatures" = "'calt', 'ss01', 'ss02', 'ss03', 'ss04', 'ss06', 'ss07', 'ss08', 'ss09', 'liga'";
          "git.enableSmartCommit" = true;
          "git.autofetch" = false;
          "git.confirmSync" = false;
          "editor.fontFamily" = "monospace";
          "editor.fontSize" = 15;
          "editor.formatOnSave" = true;

          "editor.codeActionsOnSave" = {
            "source.organizeImports.biome" = "explicit";
          };

          "workbench.colorTheme" = "nightfall";
          "git.openRepositoryInParentFolders" = "always";
          "security.workspace.trust.enabled" = false;
          "typescript.inlayHints.parameterNames.enabled" = "all";

          "nix.formatterPath" = "${pkgs.alejandra}/bin/alejandra";
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "${pkgs.nil}/bin/nil";
          "nix.serverSettings" = {
            "nil.formatting.command" = ["${pkgs.alejandra}/bin/alejandra"];
          };
          "github.copilot.nextEditSuggestions.enabled" = true;
          "vim.useSystemClipboard" = true;
        };

        extensions = with pkgs;
          (with vscode-extensions; [
            biomejs.biome
            vscodevim.vim
            mkhl.direnv
            esbenp.prettier-vscode
            dbaeumer.vscode-eslint
            usernamehw.errorlens
            eamodio.gitlens
            github.vscode-github-actions
            editorconfig.editorconfig
            bradlc.vscode-tailwindcss
            jnoortheen.nix-ide
            rust-lang.rust-analyzer
            github.copilot
            github.copilot-chat
          ])
          ++ (
            pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "nightfall";
                publisher = "nightfall";
                version = "0.0.3";
                sha256 = "sha256-E7BXc9P3RKIXTh3Vb6/r6SJIdfvJB3puXDd6FuQDr9w=";
              }
              {
                name = "effect-vscode";
                publisher = "effectful-tech";
                version = "0.1.7";
                sha256 = "sha256-qLTqOxQCTIn/tzbTU51D/XpOYnPn1M1/8UNv30t9hDE=";
              }
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
  };
}
