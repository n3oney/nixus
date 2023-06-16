{
  inputs = {
    nixpkgs-lemmy.url = "github:CobaltCause/nixpkgs/lemmy-module-improvements";
    nixpkgs-lemmy-update.url = "github:adisbladis/nixpkgs/lemmy-0_17_4";
  };

  system = {
    lib,
    inputs,
    pkgs,
    ...
  }: {
    networking.firewall.interfaces.eth0.allowedTCPPorts = [443 80];

    disabledModules = ["services/web-apps/lemmy.nix"];

    imports = [
      "${inputs.nixpkgs-lemmy}/nixos/modules/services/web-apps/lemmy.nix"
    ];

    systemd.services.lemmy-ui.environment.LEMMY_UI_EXTRA_THEMES_FOLDER = ./custom-themes;

    services.lemmy = {
      server.package = inputs.nixpkgs-lemmy-update.outputs.legacyPackages.${pkgs.system}.lemmy-server;
      ui.package = inputs.nixpkgs-lemmy-update.outputs.legacyPackages.${pkgs.system}.lemmy-ui.overrideAttrs (old: {
        patches = [./patches/0001-fix-custom-themes.patch];
      });
      database.createLocally = true;
      database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
      enable = true;
      settings = {
        hostname = "lemmy.neoney.dev";
        # gotta config this in the future
        # but I don't think this is doable
        # unless I can load stmp_password
        # from an environment variable or file
        # email = {
        #   # Hostname and port of the smtp server
        #   smtp_server = "localhost:25";
        #   # Login name for smtp server
        #   smtp_login = "string";
        #   # Password to login to the smtp server
        #   smtp_password = "string";
        #   # Address to send emails from, eg "noreply@your-instance.com"
        #   smtp_from_address = "noreply@example.com";
        #   # Whether or not smtp connections should use tls. Can be none, tls, or starttls
        #   tls_type = "none";
        # };
      };
      caddy.enable = true;
    };
  };
}
