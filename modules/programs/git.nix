_: {
  hm.programs.git = {
    enable = true;
    userName = "n3oney";
    userEmail = "neo@neoney.dev";
    extraConfig = {
      pull.rebase = true;
      init.defaultBranch = "main";
    };
  };
}
