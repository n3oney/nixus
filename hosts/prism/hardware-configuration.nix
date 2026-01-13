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

  # Custom EDID for eDP panel with extended VRR range (36-165Hz instead of stock 60-165Hz)
  # This enables lower refresh rates for better battery life when idle
  hardware.firmware = [
    (pkgs.runCommandNoCC "edid-edp-vrr" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${./firmware/edid/edp-vrr-36-165.bin} $out/lib/firmware/edid/edp-vrr-36-165.bin
    '')
  ];
  boot.kernelParams = [
    "drm.edid_firmware=eDP-1:edid/edp-vrr-36-165.bin"
    "amdgpu.freesync_video=1" # Enable FreeSync/VRR support
  ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/nvme0n1p5";
    preLVM = true;
    # For fingerprint unlock (after enrolling with systemd-cryptenroll):
    # cryptTabOptions = ["fido2-device=auto"];
  };

  fileSystems = let
    generalOptions = ["noatime" "discard" "ssd" "compress=zstd"];
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
