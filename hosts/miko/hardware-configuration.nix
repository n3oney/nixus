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

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];

  boot.extraModulePackages = with config.boot.kernelPackages; [v4l2loopback.out];
  boot.initrd.kernelModules = [];
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.kernelModules = ["kvm-amd" "amdgpu"];

  # boot.tmp.useTmpfs = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=14G" "mode=755"];
  };

  fileSystems."/etc/ssh" = {
    depends = ["/persist"];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@nix" "compress=zstd"];
  };

  fileSystems."/persist" = {
    neededForBoot = true;
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@persist" "compress=zstd"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = ["noatime" "discard"];
  };

  fileSystems."/swap" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@swap"];
  };

  fileSystems."/tmp" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "btrfs";
    options = ["noatime" "discard" "subvol=@tmp"];
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      size = 8192;
    }
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.rocmSupport = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.amdgpu.opencl.enable = true;
}
