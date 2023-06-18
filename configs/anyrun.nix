{
  inputs = {
    anyrun.url = "github:notashelf/anyrun";
    anyrun-ha-assist.url = "github:n3oney/anyrun-ha-assist";
  };

  system = _: {
    nix.settings = {
      substituters = ["https://anyrun.cachix.org"];

      trusted-public-keys = [
        "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
      ];
    };
  };

  add = {anyrun, ...}: {
    homeModules = [anyrun.homeManagerModules.default];
  };

  home = {
    inputs,
    pkgs,
    config,
    lib,
    ...
  }: {
    programs.anyrun = {
      enable = true;

      config = {
        verticalOffset.fraction = 0.3;
        closeOnClick = true;
        hidePluginInfo = true;
        showResultsImmediately = true;
        plugins = [
          "libapplications.so"
          "librink.so"
          inputs.anyrun-ha-assist.packages.${pkgs.system}.default
          "libtranslate.so"
        ];
      };

      extraConfigFiles."ha-assist.ron".source = config.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix.d/1/ha_assist_config";

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
        }

        #match.activatable:selected {
          background: #${config.colorScheme.colors.accent};
          color: black;
        }

        #match-title, #match-desc {
          color: inherit;
        }

        #entry {
          color: white;
          box-shadow: none;
          border-radius: 12px;
          border: 2px solid #${config.colorScheme.colors.accent};
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
  };
}
