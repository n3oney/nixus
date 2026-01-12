{
  config,
  lib,
  ...
}: {
  options.fingerprint.enable = lib.mkEnableOption "Fingerprint authentication";

  config = lib.mkIf config.fingerprint.enable {
    os = {
      # Enable fprintd service
      services.fprintd.enable = true;

      # Ensure fprintd starts at boot
      systemd.services.fprintd = {
        wantedBy = ["multi-user.target"];
        serviceConfig.Type = "simple";
      };
    };
  };
}
