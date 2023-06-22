{
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    eww = {
      url = "github:ralismark/eww/tray-3";
      # url = "github:elkowar/eww";
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
      (inputs.eww.packages.${pkgs.system}.eww-wayland.overrideAttrs (old: {
        buildInputs = old.buildInputs ++ (with pkgs; [glib librsvg libdbusmenu-gtk3]);
      }))
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

      check {
        border-radius: 9999px;
        min-width: 13px;
        min-height: 13px;
        background: rgba(255, 255, 255, 0.2);
        margin-right: 0.5rem;
        box-shadow: 0px 4px 4px -3px rgba(0,0,0,0.5);
      }

      check:checked {
        background: #${colorScheme.accent};
        box-shadow: inset 0px 4px 4px -3px rgba(0,0,0,0.5);
      }

      menu {
        background: #${footColors.background};
        border-bottom-left-radius: 12px;
        border-bottom-right-radius: 12px;
        border: 2px solid #${colorScheme.accent};
        padding: 1rem 0;
      }

      menu menu {
        border-top-left-radius: 12px;
        border-top-right-radius: 12px;
      }

      menu>menuitem {
        padding: 0.4em 1.5rem;
        background: transparent;
        transition: 0.2s ease background;
      }

      menu>menuitem:hover {
        background: rgba(255, 255, 255, 0.1);
      }

      menu>menuitem check:checked ~ label {
        color: #${colorScheme.accent};
        font-weight: 600;
      }

      menubar>menuitem {
        margin-left: 0.6rem;
      }

      .ewwbar {
        font-family: 'gg sans', 'Font Awesome 6 Free Solid';
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

        .wlsunset {
          margin-right: 6px;
          transition: color 0.3s ease;

          &.force_high {
            color: #ff7c1f;
          }

          &.force_low {
            color: #4d5d91;
          }
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

        /* GitHub Notifs Bell */
        .bell {
          padding-right: 0px;
          opacity: 0.3;
          transition: 0.3s ease all;
        }

        .unread .bell {
          opacity: 1;
          padding-right: 5px;
        }

        .count {
          background: #F5BDE6;
          border-radius: 9999px;
          color: #1E2030;
          font-weight: 700;
          margin-bottom: 15px;
          margin-left: 5px;
          font-size: 8px;

          opacity: 0;
          transition: 0.3s ease opacity;
        }

        .unread .count {
          opacity: 1;
        }
      }


      .yubikey-state-wrapper {
        .yubikey-state-box {
          background: rgba(#${footColors.background}, ${toString (footColors.alpha * 100)}%);
          padding: 16px;
          border-radius: 12px;

          margin: 32px 64px 64px 64px;

          box-shadow: 0px 2px 33px -5px rgba(0, 0, 0, 0.5);

          border: 2px solid #${colorScheme.accent};

          .header {
            font-size: 2rem;
            font-weight: 700;
          }

          .label {
            font-size: 1.2rem;
            font-weight: 500;
          }
        }
      }
    '';
  };
}
