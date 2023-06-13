{
  inputs = {
    neovim-flake.url = "/home/neoney/code/neovim-flake";
  };

  add = {neovim-flake, ...}: {
    homeModules = [neovim-flake.homeManagerModules.default];
  };

  home = {
    inputs,
    pkgs,
    ...
  }: {
    programs.neovim-flake = {
      enable = true;
      settings = {
        vim = {
          presence.presence-nvim = {
            enable = true;
            auto_update = true;
            image_text = "The Superior Text Editor";
            client_id = "793271441293967371";
            main_image = "neovim";
            rich_presence = {
              editing_text = "Editing %s";
            };
          };

          maps = {
            terminal = {
              "<S-BS>" = {action = "<BS>";};
              "<C-BS>" = {action = "<BS>";};
              "<M-S-BS>" = {action = "<BS>";};
              "<M-C-BS>" = {action = "<BS>";};
              "<C-S-BS>" = {action = "<BS>";};
              "<M-C-S-BS>" = {action = "<BS>";};
              "<S-Space>" = {action = "<Space>";};
              "<M-S-Space>" = {action = "<Space>";};
              "<M-C-Space>" = {action = "<Space>";};
              "<C-S-Space>" = {action = "<Space>";};
              "<M-C-S-Space>" = {action = "<Space>";};
              "<S-CR>" = {action = "<CR>";};
              "<C-CR>" = {action = "<CR>";};
              "<M-S-CR>" = {action = "<CR>";};
              "<M-C-CR>" = {action = "<CR>";};
              "<C-S-CR>" = {action = "<CR>";};
              "<M-C-S-CR>" = {action = "<CR>";};
            };

            normal = {
              "D" = {
                action = "\"_d";
              };
            };

            visual = {
              "D" = {
                action = "\"_d";
              };
            };
          };
          git.enable = true;
          wordWrap = false;
          theme = {
            enable = true;
            name = "catppuccin";
            style = "macchiato";
          };
          comments.comment-nvim = {
            enable = true;
            mappings = {
              toggleCurrentLine = "<leader>/";
              toggleSelectedLine = "<leader>/";
            };
          };
          telescope.enable = true;
          notes.todo-comments = {
            enable = true;
          };
          tabline.nvimBufferline = {
            enable = true;
            mappings = {
              closeCurrent = "<leader>c";
              cycleNext = "L";
              cyclePrevious = "H";
            };
          };
          filetree.nvimTreeLua = {
            openOnSetup = false;
            enable = true;
            view.width = 25;
            mappings = {
              toggle = "<leader>e";
            };
          };
          lsp = {
            # trouble.enable = true;
            enable = true;
            formatOnSave = true;
            lightbulb.enable = true;
            lspSignature.enable = true;
            nvimCodeActionMenu = {
              enable = true;
              mappings.open = "<leader>la";
            };
          };
          languages = {
            ts = {
              enable = true;
              treesitter.enable = true;
              lsp.enable = true;
              format.enable = true;
              extraDiagnostics.enable = true;
            };
            rust = {
              enable = true;
              lsp.enable = true;
              treesitter.enable = true;
              crates.enable = true;
            };
            nix = {
              enable = true;
              treesitter.enable = true;
              lsp.enable = true;
              format.enable = true;
            };
            html = {
              enable = true;
              treesitter = {
                enable = true;
                autotagHtml = true;
              };
            };
          };
          autocomplete.enable = true;
          visuals = {
            enable = true;
            nvimWebDevicons.enable = true;
            indentBlankline = {
              enable = true;
              fillChar = null;
              eolChar = null;
            };
          };
          treesitter = {
            enable = true;
            context.enable = true;
            fold = true;
            mappings.incrementalSelection = {
              init = "<leader>sel";
            };
          };
          viAlias = true;
          terminal.toggleterm = {
            enable = true;
            mappings.open = "<leader>tv";
            direction = "vertical";
            lazygit.enable = true;
          };
          ui.noice.enable = true;
          binds.whichKey.enable = true;
          utility.motion.leap.enable = true;
          assistant.copilot = {
            enable = true;
            mappings = {
              panel.open = "<M-p>";
              suggestion = {
                acceptWord = null;
                accept = "<M-j>";
                acceptLine = "<M-u>";
              };
            };
          };
        };
      };
    };
  };
}
