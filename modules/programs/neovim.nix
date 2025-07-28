{
  config,
  lib,
  inputs,
  pkgs,
  osConfig,
  ...
}: {
  options.programs.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf config.programs.neovim.enable {
    osModules = [inputs.nvf.nixosModules.default];

    os.environment.variables.EDITOR = "${osConfig.programs.nvf.finalPackage}/bin/nvim";

    os.programs.nvf = {
      enable = true;
      settings.vim = {
        keymaps = [
          # alt backspace to delete word backwards
          {
            key = "<M-BS>";
            mode = ["i"];
            action = "<C-W>";
          }

          # ctrl+j = leap (i+n)
          # ctrl+alt+jf leap backward (i+n)
          {
            key = "<C-j>";
            mode = ["n"];
            action = ":lua require('leap').leap {}<CR>";
          }
          {
            key = "<C-j>";
            mode = ["i"];
            lua = true;
            action = "function() require('leap').leap {} end";
          }

          {
            key = "<C-M-j>";
            mode = ["n"];
            action = ":lua require('leap').leap { backward = true }<CR>";
          }

          {
            key = "<C-M-j>";
            mode = ["i"];
            lua = true;
            action = "function() require('leap').leap { backward = true } end";
          }
        ];

        clipboard = {
          enable = true;
          providers.wl-copy.enable = true;
          registers = "unnamedplus";
        };
        # useSystemClipboard = true;
        ui = {
          fastaction.enable = true;
          fastaction.setupOpts = {
            popup = {
              relative = "cursor";
            };
          };
          smartcolumn.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
          noice.enable = true;
        };
        assistant.copilot = {
          enable = true;
          cmp.enable = true;
        };

        viAlias = true;
        vimAlias = true;
        lsp = {
          lspconfig.enable = true;
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          lspSignature.enable = true;
          mappings = {
            hover = "<leader>h";
            codeAction = "<leader>.";
          };
        };
        telescope = {
          enable = true;
          setupOpts.defaults.vimgrep_arguments = [
            "${pkgs.ripgrep}/bin/rg"
            "--color=never"
            "--no-heading"
            "--with-filename"
            "--line-number"
            "--column"
            "--smart-case"
            "--hidden"
          ];
          mappings.liveGrep = "<leader>/";
        };
        autocomplete = {
          nvim-cmp.enable = false;
        };
        utility = {
          surround.enable = true;
          motion.leap.enable = true;
          motion.precognition.enable = true;
          ccc.enable = true;
        };
        autopairs.nvim-autopairs.enable = true;
        theme = {
          enable = true;
          name = "rose-pine";
          style = "main";
        };
        treesitter.enable = true;
        binds = {
          whichKey.enable = true;
          cheatsheet.enable = true;
        };
        languages = {
          nix = {
            enable = true;
            format.enable = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          clang = {
            enable = true;
            cHeader = true;
            lsp.enable = true;
            treesitter.enable = true;
          };
          ts = {
            enable = true;
            lsp.enable = true;
            treesitter.enable = true;
            extensions.ts-error-translator.enable = true;
          };
        };
      };
    };
  };
}
