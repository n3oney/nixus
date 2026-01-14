{
  config,
  lib,
  ...
}: {
  options.services.podman.enable = lib.mkEnableOption "podman";

  config = lib.mkIf config.services.podman.enable {
    impermanence.userDirs = [".local/share/containers"];
    os.virtualisation.podman = {
      enable = true;
      dockerCompat = true;

      defaultNetwork.settings.dns_enabled = true;
    };
  };
}
