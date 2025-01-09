{
  config,
  lib,
  inputs,
  pkgs,
  ...
}: {
  options.programs.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf config.programs.neovim.enable {
    osModules = [inputs.nvf.nixosModules.default];

    os.programs.nvf = {
      enable = true;
      settings.vim = {
        keymaps = [
          {
            key = "<M-BS>";
            mode = ["i"];
            action = "<C-W>";
          }
        ];

        useSystemClipboard = true;
        ui = {
          fastaction.enable = true;
          smartcolumn.enable = true;
          borders.plugins.fastaction.enable = true;
          illuminate.enable = true;
          modes-nvim.enable = true;
        };
        assistant.copilot = {
          enable = true;
          cmp.enable = true;
        };

        viAlias = true;
        vimAlias = true;
        lsp = {
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
          nvim-cmp.enable = true;
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
