{
  system = _: {
    services.physlock = {
      enable = true;
      allowAnyUser = true;

      lockOn = {
        suspend = false;
        hibernate = false;
      };
    };

    security.pam.services.gtklock = {};
  };

  home = {pkgs, ...}: {
    home.packages = with pkgs; [gtklock physlock];
  };
}
