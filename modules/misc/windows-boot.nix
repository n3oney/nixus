{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.windowsBoot;
  
  windowsScript = pkgs.writeShellScriptBin "windows" ''
    ${pkgs.efibootmgr}/bin/efibootmgr --bootnext ${cfg.bootEntry} && reboot
  '';
in {
  options.windowsBoot = {
    enable = lib.mkEnableOption "Windows boot script";
    
    bootEntry = lib.mkOption {
      type = lib.types.str;
      description = "EFI boot entry for Windows (e.g., '0032', '0004')";
    };
    
    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = windowsScript;
      description = "The final windows boot script package";
    };
  };

  config = lib.mkIf cfg.enable {
    os.environment.systemPackages = [cfg.finalPackage];
    
    os.security.sudo.extraRules = [{
      commands = [
        { command = "${cfg.finalPackage}/bin/windows"; options = ["NOPASSWD"]; }
      ];
      groups = ["wheel"];
    }];
    
    hm.wayland.windowManager.hyprland.settings.bind = [
      "SUPER, XF86Launch9, exec, sudo ${cfg.finalPackage}/bin/windows"
    ];
  };
}
