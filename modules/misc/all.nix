{lib, ...}: {
  os = {
    boot.swraid.enable = lib.mkForce false;
    documentation = {
      enable = true;
      doc.enable = false;
      info.enable = false;
      # dev.enable = lib.mkForce true;
      man = {
        generateCaches = false;
        man-db.enable = false;
        mandoc.enable = true;
      };
    };

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
