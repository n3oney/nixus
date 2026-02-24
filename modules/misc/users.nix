{
  lib,
  config,
  ...
}: let
  cfg = config.users;
  inherit (lib) mkOption types;
in {
  options.users = {
    main = mkOption {
      type = types.str;
    };
  };

  config = {
    os = {
      users.groups.plugdev = {};
      users.users.root.hashedPasswordFile = "/persist/passwords/root";
      users.users.${cfg.main} = {
        uid = 1000;
        hashedPasswordFile = "/persist/passwords/${cfg.main}";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "video"
          "audio"
          "networkmanager"
          "lp"
          "pulse-access"
          "dialout"
          "input"
          "render"
          "kvm"
          "plugdev"
          "systemd-journal"
        ];
      };
      users.mutableUsers = false;
    };
    hmUsername = cfg.main;
  };
}
