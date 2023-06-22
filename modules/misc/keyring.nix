{
  config,
  lib,
  ...
}: {
  options.keyring.enable = lib.mkEnableOption "keyring";

  config = lib.mkIf config.keyring.enable {
    os.services.gnome.gnome-keyring.enable = true;

    hm.services.gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
  };
}
