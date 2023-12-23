{
  # config,
  lib,
  # pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["usbhid" "dm-snapshot"];

  boot.initrd.luks.devices = {
    nixos-enc = {
      device = "/dev/nvme0n1p6";
      preLVM = true;
      /*
      yubikey = {
        slot = 2;
        twoFactor = true;
        storage.device = "/dev/disk/by-label/NIXBOOT";
      };
      */
    };
  };

  /*
  boot.tmp.useTmpfs = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=8G" "mode=755"];
  };
  */

  fileSystems."/" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@persist" "compress=zstd"];
  };

  fileSystems."/nix" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@nix" "compress=zstd"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4BD8-1D05";
    fsType = "vfat";
    options = ["noatime" "discard"];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  hardware.asahi = {
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    useExperimentalGPUDriver = true;
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
