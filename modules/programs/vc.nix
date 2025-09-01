{pkgs, ...}: {
  hm = let
    name = "n3oney";
    email = "neo@neoney.dev";
  in {
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = {
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
        };
        revset-aliases = {
          "closest_bookmark(to)" = "heads(::to & bookmarks())";
        };
        user = {
          inherit email name;
        };
        ui = {
          diff-formatter = ["${pkgs.difftastic}/bin/difft" "--color=always" "$left" "$right"];
          conflict-marker-style = "git";
        };
      };
    };

    home.packages = [pkgs.jjui];

    programs.git = {
      enable = true;
      userName = name;
      userEmail = email;
      extraConfig = {
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

    programs.lazygit = {
      enable = true;
      settings = {
        git.paging.externalDiffCommand = "difft --color=always";
      };
    };
  };
}
