_: {
  hm.programs.git = {
    enable = true;
    userName = "n3oney";
    userEmail = "neo@neoney.dev";
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

  hm.programs.lazygit = {
    enable = true;
    settings = {
      git.paging.externalDiffCommand = "difft --color=always";
    };
  };
}
