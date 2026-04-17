{...}: {
  os.programs.direnv = {
    enable = true;
    enableXonshIntegration = true;
    nix-direnv.enable = true;
  };
}
