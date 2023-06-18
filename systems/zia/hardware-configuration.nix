{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.extraModulePackages = [config.boot.kernelPackages.broadcom_sta];
  boot.kernelModules = ["kvm-intel" "wl"];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];

  boot.tmp.useTmpfs = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
    options = ["noatime" "discard"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = ["noatime" "discard"];
  };

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8192;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
