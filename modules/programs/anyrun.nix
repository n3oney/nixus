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
    (lib.mkIf config.programs.anyrun.enable {
      impermanence.userFiles = [".cache/anyrun-ha-assist.sqlite3"];

      os.nix.settings = {
        substituters = ["https://anyrun.cachix.org"];

        trusted-public-keys = [
          "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
        ];
      };

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

        extraConfigFiles."ha-assist.ron".source = hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix/ha_assist_config";

        extraConfigFiles."nixos-options.ron".text = let
          nixos-options = osConfig.system.build.manual.optionsJSON + "/share/doc/nixos/options.json";
          hm-options = inputs.home-manager.packages.${pkgs.system}.docs-json + "/share/doc/home-manager/options.json";
          options = builtins.toJSON {
            ":nix" = [nixos-options];
            ":hm" = [hm-options];
          };
        in ''
          Config(
            options: ${options},
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
            padding: 12px 14px;
            border-radius: 12px;

            color: white;
            margin-top: 4px;
            border: 2px solid transparent;
            transition: all 0.3s ease;
          }

          #match.activatable:not(:first-child) {
            border-top-left-radius: 0;
            border-top-right-radius: 0;
            border-top: 2px solid rgba(255, 255, 255, 0.1);
          }

          #match.activatable #match-title {
            font-size: 1.3rem;
          }

          #match.activatable:hover {
            border: 2px solid rgba(255, 255, 255, 0.4);
          }

          #match-title, #match-desc {
            color: inherit;
          }

          #match.activatable:hover, #match.activatable:selected {
            border-top-left-radius: 12px;
            border-top-right-radius: 12px;
          }

          #match.activatable:selected + #match.activatable, #match.activatable:hover + #match.activatable {
            border-top: 2px solid transparent;
          }

          #match.activatable:selected, #match.activatable:hover:selected {
            background: rgba(255,255,255,0.1);
            border: 2px solid #${hmConfig.colorScheme.palette.accent};
            border-top: 2px solid #${hmConfig.colorScheme.palette.accent};
          }

          #match, #plugin {
            box-shadow: none;
          }

          #entry {
            color: white;
            box-shadow: none;
            border-radius: 12px;
            border: 2px solid #${hmConfig.colorScheme.palette.accent};
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
