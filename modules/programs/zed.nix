{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config.os = lib.mkIf config.programs.zed.enable {
    systemd.tmpfiles.settings = {
      "10-zed" = {
        "/home/neoney/.local/share/zed".d = {
          group = "users";
          user = "neoney";
          mode = "0755";
        };

        "/home/neoney/.local/share/zed/languages".d = {
          group = "users";
          user = "neoney";
          mode = "0755";
        };

        "/home/neoney/.local/share/zed/languages/eslint".d = {
          group = "users";
          user = "neoney";
          mode = "0755";
        };
      };
    };
  };

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
            "provider": "zed.dev",
            "model": "claude-3-5-sonnet-20240620"
            ${
        /*
        "provider": "copilot_chat",
         "model": "gpt-4o"
        */
        ""
      }
          },
          "version": "2"
        },
        "ui_font_size": 16,
        "buffer_font_size": 14,
        "buffer_font_family": "monospace",
        "theme": {
          "mode": "system",
          "light": "Rosé Pine Moon",
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
          "eslint": {
            "binary": {
              "path_lookup": true
            }
          },
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
