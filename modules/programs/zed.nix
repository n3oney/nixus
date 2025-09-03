{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.zed.enable = lib.mkEnableOption "Zed";

  config = lib.mkIf config.programs.zed.enable {
    impermanence.userDirs = [
      ".local/share/zed/debug_adapters"
      ".local/share/zed/languages"
      ".local/share/zed/extensions"
      ".local/share/zed/prettier"
      ".local/share/zed/conversations"
      ".local/share/zed/copilot"
      ".local/share/zed/db"
      ".local/share/zed/threads"
      ".local/share/zed/prompts"
    ];

    hm = lib.mkIf config.programs.zed.enable {
      programs.zed-editor = {
        enable = true;
        package =
          pkgs.zed-editor.override {withGLES = pkgs.system != "x86_64-linux";};
        userKeymaps = [
          {
            bindings = {
              "ctrl-f" = "project_search::ToggleFocus";
            };
          }
        ];
        userSettings = {
          minimap = {
            show = "auto";
            current_line_highlight = "line";
          };
          edit_predictions = {
            mode = "eager";
            copilot = {
              proxy = null;
              proxy_no_verify = null;
              enterprise_uri = null;
            };
            enabled_in_text_threads = false;
          };
          features = {
            edit_prediction_provider = "zed";
          };
          agent = {
            play_sound_when_agent_done = true;
            default_model = {
              provider = "zed.dev";
              model = "claude-sonnet-4";
            };
          };
          load_direnv = "direct";
          vim_mode = true;
          theme = "Min Dark (Blurred)";
          ui_font_size = 14;
          buffer_font_size = 14;
          languages = {
            TypeScript.language_servers = ["tsgo" "vtsls"];
          };
          wrap_guides = [60 80 120];
          show_wrap_guides = true;
          icon_theme = "JetBrains New UI Icons (Dark)";
        };
        extensions = ["tsgo" "nix" "min-theme"];
      };
    };
  };
}
