{
  config,
  lib,
  ...
}: {
  options.services.podman.enable = lib.mkEnableOption "podman";

  config.os.virtualisation.podman = lib.mkIf config.services.podman.enable {
    enable = true;
    dockerCompat = true;

    defaultNetwork.settings.dns_enabled = true;
  };
}
