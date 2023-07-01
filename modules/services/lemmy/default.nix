{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  config.inputs.catppuccin-lemmy.url = "github:n3oney/catppuccin-lemmy";

  options.services.lemmy.enable = lib.mkEnableOption "lemmy";

  config.os = lib.mkIf config.services.lemmy.enable (let
    backendPort = 8536;
    frontendPort = 1234;
    hostname = "lemmy.neoney.dev";
    uiPackage = pkgs.lemmy-ui;
    containerAddress = "10.0.0.254";
  in {
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-lemmy"];
      externalInterface = "eth0";
      enableIPv6 = true;
    };

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    containers.lemmy = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = containerAddress;
      localAddress = "10.0.0.2";
      forwardPorts = let
        mkTcp = port: {
          containerPort = port;
          hostPort = port;
          protocol = "tcp";
        };
      in [(mkTcp backendPort) (mkTcp frontendPort)];

      bindMounts = {
        "/var/lib/postgresql" = {
          hostPath = "/var/lib/lemmy/postgresql";
          isReadOnly = false;
        };
        "/var/lib/pict-rs" = {
          hostPath = "/var/lib/lemmy/pict-rs";
          isReadOnly = false;
        };
      };
      config = {
        config,
        pkgs,
        ...
      }: {
        networking.firewall.allowedTCPPorts = [backendPort frontendPort];

        systemd.services.lemmy-ui.environment = {
          LEMMY_UI_HOST = lib.mkForce "0.0.0.0:${toString frontendPort}";
          LEMMY_INTERNAL_HOST = lib.mkForce "0.0.0.0:${toString backendPort}";
          LEMMY_UI_EXTRA_THEMES_FOLDER = inputs.catppuccin-lemmy.packages.${pkgs.system}.default;
        };

        services.lemmy = {
          ui.package = uiPackage;
          database.createLocally = true;
          database.uri = "postgres:///lemmy?host=/run/postgresql&user=lemmy";
          enable = true;
          settings = {
            inherit hostname;
            bind = "0.0.0.0";

            # TODO: Setup e-mail when
            # https://github.com/LemmyNet/lemmy/pull/3154
            # lands
          };
          caddy.enable = false;
          nginx.enable = false;
        };

        system.stateVersion = "23.11";
      };
    };

    networking.firewall.allowedTCPPorts = [80 443];

    services.caddy = {
      enable = true;
      virtualHosts.${hostname} = {
        extraConfig = ''
          handle_path /static/* {
            root * ${uiPackage}/dist
            file_server
          }
          @for_backend {
            path /api/* /pictrs/* /feeds/* /nodeinfo/*
          }
          handle @for_backend {
            reverse_proxy ${containerAddress}:${toString backendPort}
          }
          @post {
            method POST
          }
          handle @post {
            reverse_proxy ${containerAddress}:${toString backendPort}
          }
          @jsonld {
            header Accept "application/activity+json"
            header Accept "application/ld+json; profile=\"https://www.w3.org/ns/activitystreams\""
          }
          handle @jsonld {
            reverse_proxy ${containerAddress}:${toString backendPort}
          }
          handle {
            reverse_proxy ${containerAddress}:${toString frontendPort}
          }
        '';
      };
    };
  });
}
