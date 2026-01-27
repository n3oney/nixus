{
  lib,
  config,
  hmConfig,
  ...
}: {
  options.programs.vivaldi.enable = lib.mkEnableOption "Vivaldi";

  config = lib.mkIf config.programs.vivaldi.enable {
    applications.vivaldi = {
      autostart = true;
      binaryPath = lib.getExe hmConfig.programs.vivaldi.finalPackage;
      defaultWorkspace = 2;
      windowClass = "vivaldi-stable";
    };

    impermanence.userDirs = [
      ".config/vivaldi"
      ".cache/vivaldi"
      ".local/lib/vivaldi"
    ];

    hm = {
      programs.vivaldi = {
        enable = true;
        extensions = [
          "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
          "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
        ];
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation"
          "--ozone-platform=wayland"
        ];
      };

      xdg.configFile."vivaldi/themes/css/hide-tabs.css".text = ''
        /*
            Custom CSS for Vivaldi Browser providing Arc Browser-like auto-hide functionality for vertical tabs.
            Fully compatible with workspaces.
            Designed for tab bar on the left side, but should also work on the right.
        */

        :root {
            --tabbar-transition: transform .2s ease-out, opacity .2s ease-out;
            --scrollbar-width: 10px;
            --scrollbar-border-color: #9fb0cb;
            --tabbar-peek-width: 3px;
        }

        /*----- Scrollbar Styling -----*/

        #tabs-tabbar-container:is(.left, .right) .tab-strip::-webkit-scrollbar {
            padding: 0 2px !important;
            width: var(--scrollbar-width) !important;
            border: 1px solid var(--scrollbar-border-color) !important;
            border-radius: 8px !important;
        }

        #tabs-tabbar-container:is(.left, .right) .tab-strip::-webkit-scrollbar-button {
            display: none !important;
        }

        #tabs-tabbar-container:is(.left, .right) .tab-strip::-webkit-scrollbar-thumb {
            border: 2px solid transparent !important;
            border-radius: 8px !important;
        }

        /*----- Vertical Tabbar Auto-Hide Behavior -----*/

        /* Base hidden state for vertical tabbar */
        #browser:is(.tabs-left, .tabs-right) .tabbar-wrapper {
            position: absolute;
            transform: translateX(calc(-100% + var(--tabbar-peek-width)));
            transition: var(--tabbar-transition) !important;
            opacity: 0;
            z-index: 1;
        }

        /* Right side positioning */
        #browser.tabs-right .tabbar-wrapper {
            right: 0;
            transform: translateX(calc(100% - var(--tabbar-peek-width)));
        }

        /* Tab move functionality support */
        #browser.tabs-left.isblurred:where(:has(div.tab-yield-space, .tab-acceptsdrop)) .tabbar-wrapper,
        #browser.tabs-left.isblurred:is(:active, :focus) .tabbar-wrapper:is(:active, :focus) {
            transform: translateX(0);
            opacity: 1;
        }

        /* Show tabbar on hover */
        #browser:is(.tabs-left, .tabs-right) .tabbar-wrapper:hover {
            transform: translateX(0);
            transition: var(--tabbar-transition) !important;
            opacity: 1;
        }

        /* Show when mouse approaches edge of screen */
        #browser:is(.tabs-left) .mainbar:hover + .tabbar-wrapper,
        #browser:is(.tabs-right) .webpage:hover + .tabbar-wrapper {
            transform: translateX(0);
            transition: var(--tabbar-transition) !important;
            opacity: 1;
        }

        /* Show when workspace popups are active */
        #browser:is(.tabs-left, .tabs-right):has(.WorkspacePopup:visible,
            .workspace-popup:visible) .tabbar-wrapper {
            transform: translateX(0);
            transition: var(--tabbar-transition) !important;
            opacity: 1;
        }

        /* Keep tab bar visible during workspace naming */
        #browser:is(.tabs-left, .tabs-right):has(.quick-command-container.workspace-naming) .tabbar-wrapper,
        #browser:is(.tabs-left, .tabs-right):has(.workspace-naming) .tabbar-wrapper,
        #browser:is(.tabs-left, .tabs-right):has(.WorkspacePopup) .tabbar-wrapper,
        #browser:is(.tabs-left, .tabs-right):has(input[placeholder*="workspace"]) .tabbar-wrapper {
            transform: translateX(0) !important;
            transition: none !important;
            opacity: 1 !important;
        }

        /* Hide on click outside */
        html:active:not(:has(.tabbar-wrapper:hover,
            .quick-command-container.workspace-naming,
            .workspace-naming,
            input[placeholder="workspace"]:focus,
            .WorkspacePopup:visible,
            .workspace-popup:visible)) .tabbar-wrapper {
            transform: translateX(calc(-100% + var(--tabbar-peek-width))) !important;
            transition: var(--tabbar-transition) !important;
            opacity: 0 !important;
        }

        /* Fix right side hiding behavior on click outside */
        html:active:not(:has(.tabbar-wrapper:hover,
            .quick-command-container.workspace-naming,
            .workspace-naming,
            input[placeholder="workspace"]:focus,
            .WorkspacePopup:visible,
            .workspace-popup:visible)) #browser.tabs-right .tabbar-wrapper {
            transform: translateX(calc(100% - var(--tabbar-peek-width))) !important;
        }

        /* Additional reset mechanism for when tabs get stuck */
        html:active:active .tabbar-wrapper:not(:hover):not(:has(.quick-command-container.workspace-naming,
            .workspace-naming,
            input[placeholder="workspace"]:focus)) {
            transform: translateX(calc(-100% + var(--tabbar-peek-width))) !important;
            opacity: 0 !important;
        }

        /* Additional reset for right side */
        html:active:active #browser.tabs-right .tabbar-wrapper:not(:hover):not(:has(.quick-command-container.workspace-naming,
            .workspace-naming,
            input[placeholder="workspace"]:focus)) {
            transform: translateX(calc(100% - var(--tabbar-peek-width))) !important;
            opacity: 0 !important;
        }
      '';

      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "text/html" = "vivaldi-stable.desktop";
          "x-scheme-handler/http" = "vivaldi-stable.desktop";
          "x-scheme-handler/https" = "vivaldi-stable.desktop";
          "x-scheme-handler/about" = "vivaldi-stable.desktop";
          "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
        };
      };
    };
  };
}
