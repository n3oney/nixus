{
  home = _: {
    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
        settings = {};
        userChrome = "";
        userContent = "";
        withExternalGnupg = true;
      };
    };
  };
}
