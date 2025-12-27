{pkgs, ...}: {
  os.nixpkgs.overlays = [(import ../../pkgs/overlays)];

  os.environment.systemPackages = [
    (pkgs.writeShellScriptBin "windows" ''
      sudo ${pkgs.efibootmgr}/bin/efibootmgr --bootnext 0032 && sudo reboot
    '')
  ];
}
