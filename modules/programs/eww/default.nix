{
  inputs,
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.eww = {
    enable = lib.mkEnableOption "eww";
    speakerSink = lib.mkOption {
      type = lib.types.str;
      default = "";
    };
    micName = lib.mkOption {
      type = lib.types.str;
    };
  };

  config = lib.mkMerge [
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
    }
    (lib.mkIf config.programs.eww.enable {
      hm = {
        home.packages = with pkgs; [
          (inputs.eww.packages.${pkgs.system}.eww-wayland.overrideAttrs (old: {
            nativeBuildInputs = old.nativeBuildInputs ++ [pkgs.wrapGAppsHook];
            buildInputs = old.buildInputs ++ (with pkgs; [glib librsvg libdbusmenu-gtk3]);
          }))
        ];

        xdg.configFile = let
          colorScheme = config.colors.colorScheme.colors;
          files = builtins.readDir ./config;
        in
          lib.concatMapAttrs (name: _: {
            "eww/${name}" = {
              source = pkgs.substituteAll ({
                  src = ./config/${name};
                  backgroundAlpha = config.colors.backgroundAlpha;
                  pamixer = lib.getExe pkgs.pamixer;
                  pactl = "${pkgs.pulseaudio}/bin/pactl";
                  jaq = lib.getExe pkgs.jaq;
                  socat = lib.getExe pkgs.socat;
                  curl = lib.getExe pkgs.curl;
                  speakerSink = builtins.toJSON config.programs.eww.speakerSink;
                  micName = builtins.toJSON config.programs.eww.micName;
                  fish = lib.getExe pkgs.fish;
                }
                // colorScheme);
              executable = true;
            };
          })
          files;
      };
    })
  ];
}
