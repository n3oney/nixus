{
  inputs,
  pkgs,
  hmConfig,
  osConfig,
  config,
  lib,
  ...
}: {
  options.programs.anyrun.enable = lib.mkEnableOption "anyrun";

  config = lib.mkMerge [
    {
      inputs = {
        anyrun.url = "github:kirottu/anyrun";
        anyrun-ha-assist.url = "github:n3oney/anyrun-ha-assist";
        anyrun-nixos-options.url = "github:n3oney/anyrun-nixos-options";
      };
    }
    (lib.mkIf config.programs.anyrun.enable {
      os.nix.settings = {
        substituters = ["https://anyrun.cachix.org"];

        trusted-public-keys = [
          "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];
      };

      hmModules = [inputs.anyrun.homeManagerModules.default];

      hm.programs.anyrun = {
        enable = true;

        config = {
          y.fraction = 0.2;
          closeOnClick = true;
          hidePluginInfo = true;
          showResultsImmediately = true;
          maxEntries = 10;
          plugins = with inputs.anyrun.packages.${pkgs.system}; [
            applications
            rink
            inputs.anyrun-ha-assist.packages.${pkgs.system}.default
            inputs.anyrun-nixos-options.packages.${pkgs.system}.default
            translate
          ];
        };

        extraConfigFiles."ha-assist.ron".source = hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix.d/1/ha_assist_config";

        extraConfigFiles."nixos-options.ron".text = ''
          Config(
            options_path: "${osConfig.system.build.manual.optionsJSON}/share/doc/nixos/options.json"
          )
        '';

        extraCss = ''
          window {
            background: transparent; /* rgba(0, 0, 0, 0.8);*/
          }

          #match,
          #entry,
          #plugin,
          #main {
            background: transparent;
          }

          #match.activatable {
            padding: 6px;
            border-radius: 12px;
            color: white;
            margin-top: 4px;
            border: 2px solid transparent;
            transition: border 0.2s ease;
          }

          #match.activatable:selected {
            border: 2px solid #${hmConfig.colorScheme.colors.accent};
          }

          #match-title, #match-desc {
            color: inherit;
          }

          #entry {
            color: white;
            box-shadow: none;
            border-radius: 12px;
            border: 2px solid #${hmConfig.colorScheme.colors.accent};
          }

          box#main {
            background: rgba(36, 39, 58, 0.7);
            border-radius: 16px;
            padding: 8px;
            box-shadow: 0px 2px 33px -5px rgba(0, 0, 0, 0.5);
          }

          row:first-child {
            margin-top: 6px;
          }
        '';
      };
    })
  ];
}
