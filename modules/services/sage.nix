{
  lib,
  config,
  pkgs,
  ...
}: {
  options.services.sage = {
    enable = lib.mkEnableOption "SageMath";
    port = lib.mkOption {
      type = lib.types.int;
      default = 8890;
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "sage.neoney.dev";
    };
  };

  config.os = lib.mkIf config.services.sage.enable {
    systemd.services.sage = {
      after = ["network-online.target"];
      requires = ["network-online.target"];
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 5;
        User = toString config.os.users.users.sage.name;
        Group = toString config.os.users.groups.sage.name;
      };
      wantedBy = ["multi-user.target"];
      script = "${pkgs.sageWithDoc}/bin/sage --notebook=jupyter --port=${toString config.services.sage.port} /var/lib/sage";
      environment.DOT_SAGE = "/var/lib/dotsage";
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/sage 0700 ${toString config.os.users.users.sage.name} ${toString config.os.users.groups.sage.name}"
      "d /var/lib/dotsage 0700 ${toString config.os.users.users.sage.name} ${toString config.os.users.groups.sage.name}"
    ];

    users.groups.sage = {};

    users.users.sage = {
      isNormalUser = true;
      group = "sage";
    };
  };
}
