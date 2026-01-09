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
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernelModules = ["kvm-amd" "amdgpu" "iptable_nat" "iptable_filter"];
  boot.kernelParams = ["acpi_enforce_resources=lax"];

  fileSystems = let
    generalOptions = ["noatime" "discard" "ssd" "compress=zstd"];
  in {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["size=14G" "mode=755"];
    };

    # "/etc/ssh" = {
    #   depends = ["/persist"];
    #   neededForBoot = true;
    # };

    "/nix" = {
      neededForBoot = true;
      device = "/dev/disk/by-uuid/3bb92a69-2ef7-45f7-99a6-526cb8989337";
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@nix"];
    };

    "/persist" = {
      neededForBoot = true;
      device = "/dev/disk/by-uuid/3bb92a69-2ef7-45f7-99a6-526cb8989337";
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@persist"];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0256-2C79";
      fsType = "vfat";
      options = ["noatime" "discard"];
    };

    /*
    "/swap" = {
      device = "/dev/disk/by-uuid/3bb92a69-2ef7-45f7-99a6-526cb8989337";
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@swap"];
    };
    */

    "/tmp" = {
      device = "/dev/disk/by-uuid/3bb92a69-2ef7-45f7-99a6-526cb8989337";
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@tmp"];
    };
  };

  zramSwap.enable = true;

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  nixpkgs.config.rocmSupport = true;
  hardware.cpu.amd.updateMicrocode = true;
  hardware.amdgpu.opencl.enable = true;
  hardware.amdgpu.initrd.enable = true;
}
