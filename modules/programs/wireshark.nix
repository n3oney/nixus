{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.wireshark.enable = lib.mkEnableOption "wireshark";

  config.os = lib.mkIf config.programs.wireshark.enable {
    programs.wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
    users.users.neoney.extraGroups = ["wireshark"];
  };
}
