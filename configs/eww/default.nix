{
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
    };
  };

  home = {
    pkgs,
    inputs,
    config,
    ...
  }: {
    home.packages = with pkgs; [
      inputs.eww.packages.${pkgs.system}.eww-wayland
      gcc-unwrapped
      socat
      pulseaudio
      jaq
      pamixer
    ];

    xdg.configFile."eww" = {
      source = ./config;
      recursive = true;
    };

    xdg.configFile."eww/eww.scss".text = let
      footColors = config.programs.foot.settings.colors;
      colorScheme = config.colorScheme.colors;
    in ''
      * {
        all: unset;
      }

      .ewwbar {
        font-family: sans;
        margin: 0 14px;
        padding: 0 12px;
        background: rgba(#${footColors.background}, ${toString (footColors.alpha * 100)}%);
        border-bottom-left-radius: 12px;
        border-bottom-right-radius: 12px;
        border-bottom: 2px solid #${colorScheme.accent};
        border-left: 2px solid #${colorScheme.accent};
        border-right: 2px solid #${colorScheme.accent};
        transition: all 0.3s ease;
      }

      .nogaps {
        border-radius: 0px;
        border-left: 2px solid transparent;
        border-right: 2px solid transparent;
        margin: 0px;
      }

      .microphone-listeners {
        background: #f9a825;
        border-radius: 16px;
        font-size: 1px;
      }

      .screenshares {
        background: #fc0a01;
        border-radius: 16px;
        font-size: 1px;
      }

      .bar {
        .time {
          font-weight: 700;
          color: #c2c0ce;
          font-size: 16px;
        }

        .time > label:nth-child(2) {
          opacity: 0.75;
          font-size: 12px;
          margin-top: -5px;
          margin-bottom: 4px;
        }

        .poweroff,
        .reboot {
          font-size: 12px;
        }

        .power button {
          color: rgba(255, 255, 255, 0.5);
          transition: color 0.2s ease;
        }

        .windows:hover {
          color: #00a4ef;
        }

        .poweroff:hover {
          color: #f25022;
        }

        .reboot:hover {
          color: #91b6e6;
        }

        .volume {
          color: white;
          font-weight: 600;
          font-size: 16px;
          opacity: 1;
          transition: opacity 0.3s ease;
        }

        .battery {
          // color: #c2c0ce;
          font-weight: 600;
          font-size: 16px;
          opacity: 0.6;
          transition: opacity 0.3s ease, color 0.3s ease;
        }

        .battery.Charging,
        .battery-icon.Charging {
          opacity: 1;
        }

        .battery.Full,
        .battery-icon.Full {
          opacity: 1;
          color: #9ece6a;
        }

        .battery-icon {
          font-size: 38px;
          margin: -10px 0;
          opacity: 0.6;
        }

        .iphone {
          color: white;
          font-weight: 600;
          font-size: 16px;
          opacity: 1;
          transition: opacity 0.3s ease;
        }

        .iphone.disconnected {
          opacity: 0.3;
        }

        .volume.muted {
          opacity: 0.6;
        }
      }
    '';
  };
}