{lib, ...}: {
  hm.programs.eza = {
    enable = true;
    enableNushellIntegration = lib.mkForce false;
    icons = "auto";
    git = true;
  };
}
