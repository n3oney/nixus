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
      driSupport = true;
      driSupport32Bit = lib.mkForce false;
    };

    users.users = let
      keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/0tMfBBa3Mzp5WvUHKW5aniB3aGTB+Tm0DJ35kbu/QkyGnXwklEZsBIaE1T6v8YzhFPJCxoocvgsK59NAMpx672rHZ/cZtuuVSiEz0hxs+6lEgh3+0rUYMC4h6F+4RCHI01jDfiNyGNPGIsPBlYEY586nC3SlZmTbm3+PnN4d8yd7yyqUeHUP9OjyKqiErbuvGrBtURExwfHKLcaDySrvL13dptc73Rh+B+TxgZ9wYN2OGy8KDXEcpWabQp6hq5Y+ktQ+r0R0Ae1qYT1DZhVK/+S7NJG5z5o5rbuGGy3+O4ssiW/Sy39NBSJZCbaUNuZobJXpBJEqwDDSRDxdKKv3uLFo4/X54Ilvnk96zzKLORxYhNDLUUhVnRlmym2dM3NPowC9Xd0mbHBajByTSEVWSXLWMDPEBajMz1Xel/+LQFj5Hcb6a3sMKZrjDV1HtY3d7n9DOZvzCElV7Ymik8EC2E+QORnQtx+hC0iJn3cDVcsDeJ1QOeZToobOT1M7Lts5etueE1puszJIu7oZIsKXHPrun/dFS/8tdk8+5T0OLBgObwF16FiHPsLFMQx1tvDuU9P9jdwO46vHPUN3AksPbF4S/N0wyMdsqcqA5BZujMYSBUJPCBQnE5Cmju7YHGN58Fg5QBwi44HprJOZCmiQJZGz6qgPuoKD8cOu5oZfJQ== openpgp:0xAFD6D076"
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
