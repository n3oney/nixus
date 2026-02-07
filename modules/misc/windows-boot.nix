{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.windowsBoot;
in {
  options.windowsBoot = {
    enable = lib.mkEnableOption "Windows boot script";
    
    bootEntry = lib.mkOption {
      type = lib.types.str;
      description = "EFI boot entry for Windows (e.g., '0032', '0004')";
    };
  };

  config = lib.mkIf cfg.enable {
    os.environment.systemPackages = [
      (pkgs.writeShellScriptBin "windows" ''
        sudo ${pkgs.efibootmgr}/bin/efibootmgr --bootnext ${cfg.bootEntry} && sudo reboot
      '')
    ];
  };
}
