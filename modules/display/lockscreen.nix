{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.display.enable {
    os = {
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

    hm.home.packages = with pkgs; [gtklock physlock];
  };
}
