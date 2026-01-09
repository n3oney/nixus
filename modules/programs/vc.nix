{pkgs, ...}: {
  hm = let
    name = "n3oney";
    email = "neo@neoney.dev";
  in {
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = {
          ins = ["new" "--insert-after"];
          pull = ["git" "fetch"];
          push = ["git" "push"];
          tug = ["bookmark" "move" "--from" "closest_bookmark(@-)" "--to" "@-"];
          sync = [
            "rebase"
            "--source"
            "all:roots(trunk()..mutable())"
            "--destination"
            "trunk()"
          ];
          ps = ["util" "exec" "--" "sh" "-c" "jj pull && jj sync"];
          tp = ["util" "exec" "--" "sh" "-c" "jj tug && jj push"];
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
          "junk" = "empty() ~ merges() ~ root()";
          "nonmain" = "(all() ~ ::main@origin) ~ @";
        };
        user = {
          inherit email name;
        };
        ui = {
          default-command = "log";
          diff-formatter = ["${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right"];
          conflict-marker-style = "git";
          log-word-wrap = true;
          merge-editor = "${pkgs.mergiraf}/bin/mergiraf";
        };

        # Use relative timestamps (e.g. "2 hours ago")
        template-aliases."format_timestamp(timestamp)" = "timestamp.ago()";

        # Prioritize current branch for shorter commit/change ID prefixes
        revsets.short-prefixes = "(trunk()..@)::";

        # jj fix configuration - uses formatters from PATH, passes through if not available
        fix.tools = {
          # Nix formatter - alejandra from PATH
          alejandra = {
            command = ["sh" "-c" "alejandra --quiet 2>/dev/null || cat"];
            patterns = ["glob:'**/*.nix'"];
          };

          # Prettier from PATH (some projects use this)
          prettier = {
            command = ["sh" "-c" "prettier --stdin-filepath=$path 2>/dev/null || cat"];
            patterns = [
              "glob:'**/*.ts'"
              "glob:'**/*.tsx'"
              "glob:'**/*.js'"
              "glob:'**/*.jsx'"
              "glob:'**/*.json'"
              "glob:'**/*.css'"
              "glob:'**/*.html'"
              "glob:'**/*.md'"
              "glob:'**/*.yaml'"
              "glob:'**/*.yml'"
            ];
          };

          # Biome from PATH (some projects use this)
          biome = {
            command = ["sh" "-c" "biome format --stdin-file-path=$path 2>/dev/null || cat"];
            patterns = [
              "glob:'**/*.ts'"
              "glob:'**/*.tsx'"
              "glob:'**/*.js'"
              "glob:'**/*.jsx'"
              "glob:'**/*.json'"
            ];
          };
        };
      };
    };

    home.packages = [pkgs.jjui];

    programs.git = {
      enable = true;
      userName = name;
      userEmail = email;
      extraConfig = {
        url."git@github.com:".insteadOf = "https://github.com/";
        user.signingkey = "/home/neoney/.ssh/id_ed25519_sk.pub";
        gpg.format = "ssh";
        pull.rebase = true;
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
      difftastic = {
        enable = true;
        enableAsDifftool = true;
        background = "dark";
      };
    };

    programs.difftastic = {
      git.enable = true;
      enable = true;
    };

    programs.lazygit = {
      enable = true;
      settings = {
        git.paging.externalDiffCommand = "difft --color=always";
      };
    };
  };
}
