{
  inputs,
  pkgs,
  config,
  lib,
  # hmConfig,
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
          splitList = let
            splitList = n: list:
              if lib.length list == 0
              then []
              else let
                chunk = lib.sublist 0 n list;
                rest = splitList n (lib.drop n list);
              in
                [chunk] ++ rest;
          in
            splitList;
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
                  pidof = "${pkgs.procps}/bin/pidof";
                  xargs = "${pkgs.findutils}/bin/xargs";
                  idleInhibit = "${pkgs.wlroots.examples}/bin/wlroots-idle-inhibit";
                  # done twice so that it's a string
                  hyprbinds = builtins.toJSON (builtins.toJSON (splitList 5 (builtins.map (b: {
                    bind =
                      if (lib.hasPrefix ", " b.bind)
                      then (builtins.substring 2 ((builtins.stringLength b.bind) - 2) b.bind)
                      else b.bind;
                    keybind = builtins.replaceStrings [", "] [" + "] b.bind;
                    label = b.comment;
                  }) (builtins.filter (b: b.comment != null) config.display.binds))));
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
