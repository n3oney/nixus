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
  boot.initrd.kernelModules = ["vfat" "nls_cp437" "nls_iso8859-1" "usbhid"];
  boot.initrd.luks.yubikeySupport = true;

  boot.initrd.luks.devices = {
    nixos-enc = {
      device = "/dev/sda2";
      preLVM = true;
      yubikey = {
        slot = 2;
        twoFactor = true;
        storage.device = "/dev/disk/by-label/NIXBOOT";
      };
    };
  };

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
      device = "/dev/disk/by-label/swap";
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;
}
