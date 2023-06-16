{
  system = {
    lib,
    inputs,
    pkgs,
    ...
  }: {
    networking.firewall.interfaces.eth0.allowedTCPPorts = [443 80];

    systemd.services.lemmy-ui.environment.LEMMY_UI_EXTRA_THEMES_FOLDER = ./custom-themes;

    services.lemmy = {
      ui.package = pkgs.lemmy-ui.overrideAttrs (old: {
        patches = [./patches/0001-fix-custom-themes.patch];
      });
      database.createLocally = true;
      database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
      enable = true;
      settings = {
        hostname = "lemmy.neoney.dev";
        # TODO: Setup e-mail when
        # https://github.com/LemmyNet/lemmy/pull/3154
        # lands
      };
      caddy.enable = true;
    };
  };
}
