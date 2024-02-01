{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  config = {
    os = {
      environment.systemPackages = [pkgs.nushell];

      users.defaultUserShell = hmConfig.programs.nushell.package;
    };

    hm = {
      programs.nushell = {
        enable = true;

        shellAliases = {
          cd = "z";
          cat = "${lib.getExe pkgs.bat}";
        };

        extraConfig = let
          opaquewrap = binary:
            with builtins;
            with lib; ''
              printf "\\033]11;rgba:${
                concatStringsSep "/" (match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" config.colors.colorScheme.colors.base00)
              }/ff\\007"

              ^${binary} ...$args

              printf "\\033]11;rgba:${
                concatStringsSep "/" (match "([0-9a-fA-F]{2})([0-9a-fA-F]{2})([0-9a-fA-F]{2})" config.colors.colorScheme.colors.base00)
              }/${toHexString (floor (config.colors.backgroundAlpha * 255))}\\007"
            '';
        in ''
          $env.LS_COLORS = (${lib.getExe pkgs.vivid} generate catppuccin-macchiato | str trim)

          def hd [--nh_args: list<string> = [], --nix_args: list<string> = []] {
            let params = ["nh" "os" "switch" ...$nh_args "--" "--impure" ...$nix_args];
            $params | run-external $params.0 ...($params | skip 1)
          }

          def hx [...args] {
            ${opaquewrap "hx"}
          }

          def btop [...args] {
            ${opaquewrap "btop"}
          }

          export-env { load-env {
              STARSHIP_SHELL: "nu"
              STARSHIP_SESSION_KEY: (random chars -l 16)
              PROMPT_MULTILINE_INDICATOR: (
                  ^/etc/profiles/per-user/neoney/bin/starship prompt --continuation
              )

              # Does not play well with default character module.
              # TODO: Also Use starship vi mode indicators?
              PROMPT_INDICATOR: ""

              PROMPT_COMMAND: {||
                  # jobs are not supported
                  (
                      ^/etc/profiles/per-user/neoney/bin/starship prompt
                          --cmd-duration $env.CMD_DURATION_MS
                          $"--status=($env.LAST_EXIT_CODE)"
                          --terminal-width (term size).columns
                  )
              }

              config: ($env.config? | default {} | merge {
                  render_right_prompt_on_last_line: true
              })

              PROMPT_COMMAND_RIGHT: {||
                  (
                      ^/etc/profiles/per-user/neoney/bin/starship prompt
                          --right
                          --cmd-duration $env.CMD_DURATION_MS
                          $"--status=($env.LAST_EXIT_CODE)"
                          --terminal-width (term size).columns
                  )
              }
          }}

          let carapace_completer = {|spans|
            ${lib.getExe pkgs.carapace} $spans.0 nushell ...$spans | from json
          }

          let fish_completer = {|spans|
            ${lib.getExe pkgs.fish} --command $'complete "--do-complete=($spans | str join " ")"'
            | $"value(char tab)description(char newline)" + $in
            | from tsv --flexible --no-infer
          }

          let zoxide_completer = {|spans|
              $spans | skip 1 | ${lib.getExe hmConfig.programs.zoxide.package} query -l $in | lines | where {|x| $x != $env.PWD}
          }

          let multiple_completers = {|spans|
            let expanded_alias = scope aliases | where name == $spans.0 | get -i 0.expansions

            let spans = if $expanded_alias != null {
              $spans | skip 1 | prepend ($expanded_alias | split row ' ' | take 1)
            } else {
              $spans
            }

            match $spans.0 {
              nu => $fish_completer,${/*carapace incorrectly completes nu*/""}
              git => $fish_completer,${/*fish completes commits and branch names nicely*/""}
              ssh => $fish_completer,${/*fish completes hosts from ssh config*/""}

              z => $zoxide_completer,

              _ => $carapace_completer
            } | do $in $spans
          }

          $env.config = {
            color_config: {
              string: "#${config.colors.colorScheme.colors.base05}"
            },
            show_banner: false,
            completions: {
              external: {
                enable: true,
                completer: $multiple_completers
              }
            },
          }
        '';
      };
    };
  };
}
