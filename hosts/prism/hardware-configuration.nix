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

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["dm-snapshot"];
  boot.kernelModules = ["kvm-amd"];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-label/NIXROOT";
    preLVM = true;
    # For fingerprint unlock (after enrolling with systemd-cryptenroll):
    # cryptTabOptions = ["fido2-device=auto"];
  };

  fileSystems = let
    generalOptions = ["noatime" "discard" "ssd" "compress=zstd"];
    # TODO: Set your btrfs UUID after install
    btrfsDevice = "/dev/mapper/cryptroot";    
  in {
    "/" = {
      device = "none";
      fsType = "tmpfs";
      options = ["size=16G" "mode=755"];
    };

    "/nix" = {
      neededForBoot = true;
      device = btrfsDevice;
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@nix"];
    };

    "/persist" = {
      neededForBoot = true;
      device = btrfsDevice;
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@persist"];
    };

    "/tmp" = {
      device = btrfsDevice;
      fsType = "btrfs";
      options = generalOptions ++ ["subvol=@tmp"];
    };

    # TODO: Set your boot partition UUID after install
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = ["noatime" "discard"];
    };
  };

  zramSwap.enable = true;

  services.upower.enable = true;

  networking.useDHCP = lib.mkDefault true;

  hardware.cpu.amd.updateMicrocode = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
