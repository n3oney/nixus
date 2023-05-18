{
  system = _: {
    services.gnome.gnome-keyring.enable = true;
  };

  home = _: {
    services.gnome-keyring = {
      enable = true;
      components = ["secrets"];
    };
  };
}
