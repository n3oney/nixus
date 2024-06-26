{
  # osConfig,
  # pkgs,
  lib,
  inputs,
  pkgs,
  ...
}: {
  osModules = [inputs.apple-silicon-support.nixosModules.apple-silicon-support ./hardware-configuration.nix];

  os = let
    box64 = pkgs.box64.overrideAttrs (old: {
      version = "unstable-2024-01-29";
      src = pkgs.fetchFromGitHub {
        owner = "ptitSeb";
        repo = "box64";
        rev = "9793c3b142c325d9405b1baa5959547a3f49fcaf";
        hash = "sha256-zvkSeZcDWj+3XJSo3c5MRk3e0FJhVe7FuEyEVwkCzPE=";
      };
      cmakeFlags = (old.cmakeFlags or []) ++ ["-D M1=1"];
    });
  in {
    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = false;
    };

    boot.binfmt.emulatedSystems = ["x86_64-linux"];

    networking = {
      hostName = "vic";
      wireless = {
        enable = false;
        iwd.enable = true;
        # settings.General.EnableNetworkConfiguration = true;
      };
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    sound.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    # AirPlay support
    services.avahi.enable = true;

    hardware.opengl = {
      driSupport32Bit = lib.mkForce false;
    };

    users.users = let
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      root.openssh.authorizedKeys.keys = keys;
    };

    time.timeZone = "Europe/Warsaw";

    system.stateVersion = "23.05";
  };

  hm.home.stateVersion = "23.05";
}
