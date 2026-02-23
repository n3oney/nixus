{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  options.programs.vicinae.enable = lib.mkEnableOption "vicinae";

  config = lib.mkIf config.programs.vicinae.enable {
    impermanence.userDirs = [".local/share/vicinae"];

    hm.programs.vicinae = {
      enable = true;

      systemd = {
        enable = true;
        autoStart = true;
        target = "hyprland-session.target";
      };

      useLayerShell = true;

      extensions = let
        extensionsSrc = pkgs.fetchFromGitHub {
          owner = "vicinaehq";
          repo = "extensions";
          rev = "cf30b80f619282d45b1748eb76e784a4f875bb01";
          sha256 = "sha256-KwNv+THKbNUey10q26NZPDMSzYTObRHaSDr81QP9CPY=";
        };
      in [
        (hmConfig.lib.vicinae.mkExtension {
          name = "nix";
          src = extensionsSrc + "/extensions/nix";
        })
        (hmConfig.lib.vicinae.mkExtension {
          name = "bluetooth";
          src = extensionsSrc + "/extensions/bluetooth";
        })
        (hmConfig.lib.vicinae.mkRayCastExtension {
          name = "linear";
          rev = "3de88e0dd8da8fedcd414c6b16dba81412f04d83";
          sha256 = "sha256-hyIS8KYTONLDsn/p8MU9eWKoRYfRVlCzStnSzfUqb6s=";
        })
      ];

      settings = {
        # Reset navigation state when closing vicinae
        pop_to_root_on_close = true;

        # Fallback searches when no results match
        fallbacks = [
          "core:search-emojis"
          "files:search"
        ];

        theme = {
          dark = {
            name = "rose-pine-moon";
          };
        };

        launcher_window = {
          # Lower opacity for more transparency
          opacity = 0.75;

          # Enable blur (Hyprland-specific feature)
          blur = {
            enabled = true;
          };

          # Dim everything behind vicinae (Hyprland-specific)
          dim_around = true;

          # Layer shell configuration for Hyprland integration
          layer_shell = {
            enabled = true;
            keyboard_interactivity = "exclusive";
            layer = "top";
          };
        };
      };
    };
  };
}
