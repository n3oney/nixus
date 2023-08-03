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
      users.users.root.passwordFile = "/persist/passwords/root";
      users.users.${cfg.main} = {
        uid = 1000;
        initialHashedPassword = "$6$hAv60khFN/SnCt6r$LkoM5y7xGJPBGLr8DoNZB.mKJudpctUVZ75meQ6gTHBdp8q.dOmXgfTzZOw1.igi1gBc451Hc69TrUmqtFFqB.";
        passwordFile = "/persist/passwords/${cfg.main}";
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "video"
          "networkmanager"
          "lp"
          "pulse-access"
        ];
      };
      users.mutableUsers = false;
    };
    hmUsername = cfg.main;
  };
}
