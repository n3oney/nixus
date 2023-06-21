{
  home = _: {
    programs.git = {
      enable = true;
      userName = "n3oney";
      userEmail = "neo@neoney.dev";
      extraConfig = {
        pull.rebase = true;
      };
    };
  };
}
