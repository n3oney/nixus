{lib, ...}: {
  os = {
    boot.swraid.enable = lib.mkForce false;

    environment.etc.currentConfig.source = ../../.;

    security.pam.loginLimits = [
      {
        domain = "@users";
        item = "rtprio";
        type = "-";
        value = 1;
      }
    ];
  };
}
