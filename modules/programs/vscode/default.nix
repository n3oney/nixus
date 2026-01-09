{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.vscode.enable = lib.mkEnableOption "vscode";

  config = lib.mkIf config.programs.vscode.enable {
    impermanence.userDirs = [".config/Code/User/History" ".config/Code/User/workspaceStorage" ".config/Code/User/globalStorage" ".config/Code/WebStorage" ".config/Code/logs" ".config/Code/blob_storage" ".config/Code/Cache" ".config/Code/Code Cache" ".config/Code/CachedData" ".config/Code/CachedExtensionVSIXs" ".config/Code/CachedProfilesData" ".config/Code/Cookies" ".config/Code/Cookies-journal"];
    impermanence.userFiles = [
      ".vscode/argv.json"
      ".config/Code/SharedStorage"
      ".config/Code/SharedStorage-wal"
      ".config/Code/Trust Tokens"
      ".config/Code/Trust Tokens-journal"
    ];

    hm.programs.vscode = {
      package = pkgs.vscode.overrideAttrs (old: {
        postFixup =
          (old.postFixup or "")
          + ''
            wrapProgram $out/bin/code --add-flags "--password-store='gnome-libsecret' --disable-gpu"
          '';
      });
      enable = true;
      profiles.default = {
        userSettings = {
          "editor.fontFamily" = "monospace";
          "editor.fontSize" = 15;
          "editor.tabSize" = 2;
          "security.workspace.trust.enabled" = false;
        };

        extensions = with pkgs.vscode-extensions; [
          github.vscode-pull-request-github
        ];
      };
    };
  };
}
