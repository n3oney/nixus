{
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "amdgpu"
  ];
  boot.kernelModules = ["kvm-amd"];

  # Custom EDID for eDP panel with extended VRR range (36-165Hz instead of stock 60-165Hz)
  # This enables lower refresh rates for better battery life when idle
  hardware.firmware = [
    (pkgs.runCommand "edid-edp-vrr" {} ''
      mkdir -p $out/lib/firmware/edid
      cp ${./firmware/edid/edp-vrr-36-165.bin} $out/lib/firmware/edid/edp-vrr-36-165.bin
    '')
    # ALC245 internal mic fix:
    # - Mark ext mic jack (0x19) as not-connected so the driver never routes
    #   capture to it. Without this, jack detection is unreliable and the driver
    #   randomly routes capture to the empty external mic pin, producing silence.
    # - inv_jack_detect hint kept as defense-in-depth.
    (pkgs.writeTextFile {
      name = "alc245-internal-mic-patch";
      destination = "/lib/firmware/alc245-internal-mic.fw";
      text = ''
        [codec]
        0x10ec0245 0x1f4ce001 0

        [pincfg]
        0x19 0x411111f0

        [hint]
        inv_jack_detect = yes
      '';
    })
  ];
  boot.kernelParams = [
    "drm.edid_firmware=eDP-1:edid/edp-vrr-36-165.bin"
    "amdgpu.freesync_video=1" # Enable FreeSync/VRR support
  ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/nvme0n1p5";
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
