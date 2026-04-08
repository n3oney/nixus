{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.smarthome.otbr;
in {
  options.services.smarthome.otbr = {
    enable = lib.mkEnableOption "OpenThread Border Router" // {default = config.services.smarthome.enable;};
    serialDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/otbr-radio";
    };
    udevSerial = lib.mkOption {
      type = lib.types.str;
      default = "C05031F9271D";
      description = "ID_SERIAL_SHORT of the OTBR RCP device.";
    };
    baudrate = lib.mkOption {
      type = lib.types.int;
      default = 1000000;
    };
    backboneIf = lib.mkOption {
      type = lib.types.str;
      description = "Upstream backbone interface for OTBR.";
    };
  };

  config.os = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/otbr 0755 root root -"
    ];

    services.udev.extraRules = ''
      SUBSYSTEM=="tty", ENV{ID_SERIAL_SHORT}=="${cfg.udevSerial}", SYMLINK+="otbr-radio"
      SUBSYSTEM=="usb", ENV{ID_SERIAL_SHORT}=="${cfg.udevSerial}", ATTR{power/autosuspend}="-1"
    '';

    boot.kernelModules = [
      "iptable_nat"
      "iptable_filter"
      "iptable_mangle"
      "ip6table_filter"
      "ip6table_mangle"
    ];

    boot.kernel.sysctl = {
      "net.ipv6.conf.all.forwarding" = lib.mkForce 1;
      "net.ipv4.conf.all.forwarding" = lib.mkForce 1;
      "net.ipv6.conf.enp1s0.accept_ra" = lib.mkForce 2;
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };

    networking.firewall = {
      allowedUDPPorts = [5353];
      trustedInterfaces = [cfg.backboneIf];
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers.otbr = {
        image = "ghcr.io/ownbee/hass-otbr-docker:latest";
        environment = {
          DEVICE = "/dev/radio";
          BAUDRATE = toString cfg.baudrate;
          FLOW_CONTROL = "1";
          BACKBONE_IF = cfg.backboneIf;
          OTBR_LOG_LEVEL = "info";
          OTBR_REST_PORT = "8081";
          OTBR_WEB_PORT = "8082";
          OTBR_WEB = "1";
          FIREWALL = "1";
          NAT64 = "1";
        };
        volumes = [
          "/var/lib/otbr:/var/lib/thread"
        ];
        extraOptions = [
          "--network=host"
          "--privileged"
          "--device=${cfg.serialDevice}:/dev/radio"
        ];
      };
    };
  };
}
