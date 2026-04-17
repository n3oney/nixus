{pkgs, ...}: {
  osModules = [./hardware-configuration.nix];

  os = {
    # build rocm stuff for gfx1010
    nixpkgs.overlays = [
      (
        _final: prev: {
          rocmPackages = prev.rocmPackages.overrideScope (rocmFinal: rocmPrev: {
            clr = rocmPrev.clr.overrideAttrs (old: {
              passthru =
                (old.passthru or {})
                // {
                  localGpuTargets = ["gfx1010"];
                  gpuTargets = ["gfx1010"];
                };
            });
            miopen = rocmPrev.miopen.override {withComposableKernel = false;};
          });

          pythonPackagesExtensions =
            (prev.pythonPackagesExtensions or [])
            ++ [
              (pyFinal: pyPrev: {
                torch = pyPrev.torch.override {gpuTargets = ["gfx1010"];};
                vllm = pyPrev.vllm.overrideAttrs (o: {
                  postPatch =
                    (o.postPatch or "")
                    + ''
                      substituteInPlace CMakeLists.txt \
                        --replace-fail \
                          'set(HIP_SUPPORTED_ARCHS "gfx906;gfx908;gfx90a;gfx942;gfx950;gfx1030;gfx1100;gfx1101;gfx1200;gfx1201;gfx1150;gfx1151")' \
                          'set(HIP_SUPPORTED_ARCHS "gfx1010")'
                    '';
                });
              })
            ];
        }
      )
    ];

    nixpkgs.config.problems.handlers = {
      composable_kernel.broken = "warn";
    };

    nixpkgs.config.rocmSupport = true;

    environment.systemPackages = [
      (pkgs.python3.withPackages (ps: [ps.torch ps.transformers ps.accelerate ps.vllm ps.diffusers]))
    ];

    # for rocm
    environment.variables = {
      AMDGCN_USE_BUFFER_OPS = "0";
      HSA_OVERRIDE_GFX_VERSION = "10.1.0";
      GPU_PINNED_MIN_XFER_SIZE = "16384";
      HSA_ENABLE_SDMA = "0";
    };

    nixpkgs.config.allowUnfree = true;

    boot.loader = {
      systemd-boot.enable = true;
      systemd-boot.graceful = true;
      efi.canTouchEfiVariables = true;
    };

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;
    boot.kernelParams = ["ttm.pages_limit=4194304"];
    boot.initrd.kernelModules = ["amdgpu"];

    networking = {
      hostName = "endurance";
      networkmanager = {
        enable = true;
      };
      interfaces.enp4s0.ipv4.addresses = [
        {
          address = "192.168.1.4";
          prefixLength = 24;
        }
      ];
      defaultGateway = "192.168.1.1";
      nameservers = [
        "1.1.1.1"
        "1.0.0.1"
      ];
    };

    systemd.services.NetworkManager-wait-online.enable = false;

    users.users = let
      keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFeCIZo/mMTNeo7hcOorHs0ooTACJqiT+MGe6xUJV2BzAAAABHNzaDo= neoney@miko"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIM1855fHjbeSW54ganm9X4PKuzAUHBm8Hb78TPZE3XjoAAAABHNzaDo= yubikey_5c_nano_2025"
      ];
    in {
      neoney.openssh.authorizedKeys.keys = keys;
      neoney.linger = true;
      root.openssh.authorizedKeys.keys = keys;
    };

    services.avahi.ipv6 = false;

    services.pulseaudio = {
      enable = true;
      zeroconf.publish.enable = true;
      tcp = {
        enable = true;
        anonymousClients.allowedIpRanges = ["127.0.0.1" "192.168.1.5"];
      };
      systemWide = true;
    };

    networking.firewall.allowedTCPPorts = [4713];
    networking.firewall.allowedUDPPorts = [4713];

    hardware.firmware = [pkgs.linux-firmware];

    hardware.graphics = {
      enable = true;
      extraPackages = [pkgs.libva-utils];
    };

    time.timeZone = "Europe/Warsaw";

    system.stateVersion = "23.05";
  };

  hm.home.stateVersion = "23.05";
}
