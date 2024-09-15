{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config.hm = lib.mkIf config.programs.zed.enable {
    home.file.".local/share/zed/node/node-v22.5.1-linux-x64" = {
      recursive = true;
      source = "${pkgs.nodejs}";
    };

    home.packages = [
      (pkgs.zed-editor.override {withGLES = true;})
    ];

    xdg.configFile."zed/settings.json".text = ''
      {
        "assistant": {
          "default_model": {
            "provider": "anthropic",
            "model": "claude-3-5-sonnet-20240620"
          },
          "version": "2"
        },
        "ui_font_size": 16,
        "buffer_font_size": 16,
        "theme": {
          "mode": "system",
          "light": "Rosé Pine",
          "dark": "One Dark"
        },
        "load_direnv": "direct",
        "vim_mode": true,
        "inlay_hints": {
          "enabled": true,
          "show_type_hints": false
        },
        "journal": {
          "hour_format": "hour24"
        },
        "lsp": {
          "nixd": {
            "binary": {
              "path": "${pkgs.nixd}/bin/nixd"
            }
          }
        },
        "terminal": {
          "dock": "right"
        },
        "languages": {
          "JavaScript": {
            "formatter": {
              "external": {
                "command": "${pkgs.nodePackages.prettier}/bin/prettier",
                "arguments": ["--stdin-filepath", "{buffer_path}"]
              }
            },
            "code_actions_on_format": {
              "source.fixAll.eslint": true
            }
          },
          "TSX": {
            "formatter": {
              "external": {
                "command": "${pkgs.nodePackages.prettier}/bin/prettier",
                "arguments": ["--stdin-filepath", "{buffer_path}"]
              }
            },
            "code_actions_on_format": {
              "source.fixAll.eslint": true
            }
          },
          "TypeScript": {
            "formatter": {
              "external": {
                "command": "${pkgs.nodePackages.prettier}/bin/prettier",
                "arguments": ["--stdin-filepath", "{buffer_path}"]
              }
            },
            "code_actions_on_format": {
              "source.fixAll.eslint": true
            }
          }
        },
        "vim": {
          "use_system_clipboard": "always",
          "use_multiline_find": true,
          "use_smartcase_find": true
        },
        "relative_line_numbers": true,
        "scrollbar": {
          "show": "never"
        }
      }
    '';
  };
}
