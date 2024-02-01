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
    };

    hm = {
      programs.nushell = {
        enable = true;

        extraConfig = ''
          # this file is both a valid
          # - overlay which can be loaded with `overlay use starship.nu`
          # - module which can be used with `use starship.nu`
          # - script which can be used with `source starship.nu`
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
        '';
      };
    };
  };
}
