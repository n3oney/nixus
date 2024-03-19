{
  # config,
  lib,
  # pkgs,
  ...
}: {
  boot.initrd.availableKernelModules = ["usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = ["usbhid" "dm-snapshot"];

  services.upower.enable = true;

  boot.kernelPatches = [
    {
      name = "edge-config";
      patch = null;
      # derived from
      # https://github.com/AsahiLinux/PKGBUILDs/blob/stable/linux-asahi/config.edge
      extraConfig = ''
        DRM_SIMPLEDRM_BACKLIGHT n
        BACKLIGHT_GPIO n
        DRM_APPLE m
        APPLE_SMC m
        APPLE_SMC_RTKIT m
        APPLE_RTKIT m
        APPLE_MBOX m
        GPIO_MACSMC m
        DRM_VGEM n
        DRM_SCHED y
        DRM_GEM_SHMEM_HELPER y
        DRM_ASAHI m
        SUSPEND y
      '';
    }
    {
      name = "waydroid";
      patch = null;
      extraConfig = ''
        ANDROID_BINDER_IPC y
        ANDROID_BINDERFS y
        ASHMEM y
        MEMFD_CREATE y
        CONFIG_MEMFD_CREATE y
        CONFIG_ASHMEM y
        CONFIG_ANDROID_BINDERFS y
        CONFIG_ANDROID_BINDER_IPC y
        ANDROID_BINDER_DEVICES binder,hwbinder,vndbinder
      '';
    }
  ];

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

  boot.tmp.useTmpfs = true;

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = ["size=14G" "mode=755"];
  };

  fileSystems."/etc/ssh" = {
    depends = ["/persist"];
    neededForBoot = true;
  };

  fileSystems."/persist" = {
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
    enable = true;
    extractPeripheralFirmware = true;
    peripheralFirmwareDirectory = ./firmware;
    withRust = true;
    # addEdgeKernelConfig = true;
    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
  };

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
