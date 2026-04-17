{...}: {
  os.programs.direnv = {
    enable = true;
    enableXonshIntegration = true;
    nix-direnv.enable = true;
    settings.global.hide_env_diff = true;
  };
}
