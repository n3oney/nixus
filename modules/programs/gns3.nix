{
  config,
  lib,
  pkgs,
  ...
}: {
  options.programs.gns3.enable = lib.mkEnableOption "GNS3";

  config = lib.mkIf config.programs.gns3.enable {
    os = {
      environment.systemPackages = [
        pkgs.gns3-gui
        pkgs.inetutils # for telnet
      ];

      services.gns3-server = {
        enable = true;
        ubridge.enable = true;
        vpcs.enable = true;
        dynamips.enable = true;
      };

      # Enable libvirtd for proper QEMU/KVM support
      virtualisation.libvirtd = {
        enable = true;
        qemu = {
          package = pkgs.qemu_kvm;
        };
      };

      users.users.neoney.extraGroups = ["gns3" "ubridge" "libvirtd"];
    };

    impermanence.userDirs = ["GNS3"];
    impermanence.systemDirs = ["/var/lib/gns3" "/var/lib/libvirt"];
  };
}
