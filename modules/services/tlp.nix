{
  config,
  lib,
  ...
}: {
  options.services.tlp.enable = lib.mkEnableOption "TLP power management";

  config = lib.mkIf config.services.tlp.enable {
    # Ensure power-profiles-daemon doesn't conflict
    os.services.power-profiles-daemon.enable = false;

    os.services.tlp = {
      enable = true;
      settings = {
        # CPU governor
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # AMD P-State EPP (Energy Performance Preference)
        # Options: performance, balance_performance, balance_power, power
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        # AMD P-State driver mode
        CPU_DRIVER_OPMODE_ON_AC = "active";
        CPU_DRIVER_OPMODE_ON_BAT = "active";

        # CPU boost (turbo)
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0; # Disable turbo on battery

        # Platform power profile
        PLATFORM_PROFILE_ON_AC = "balanced";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        # Runtime PM for PCIe devices
        RUNTIME_PM_ON_AC = "auto";
        RUNTIME_PM_ON_BAT = "auto";

        # USB autosuspend
        USB_AUTOSUSPEND = 1;

        # WiFi power saving (also configured in NetworkManager, this is backup)
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";

        # PCIe ASPM
        PCIE_ASPM_ON_AC = "default";
        PCIE_ASPM_ON_BAT = "powersupersave";

        # NVMe/AHCI runtime PM
        AHCI_RUNTIME_PM_ON_AC = "on";
        AHCI_RUNTIME_PM_ON_BAT = "auto";
      };
    };
  };
}
