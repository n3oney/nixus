{
  lib,
  pkgs,
  config,
  ...
}: let
  monitors = config.display.monitors;
  mainMonitor = (lib.findFirst (m: m.isMain) (builtins.head monitors) monitors).name;

  wallpaper = ../../../wallpapers/ios13.jpg;
  wallpaperDir = pkgs.runCommand "noctalia-wallpaper" {} ''
    mkdir -p $out
    ln -s ${wallpaper} $out/ios13.jpg
  '';

  avatar = pkgs.fetchurl {
    name = "avatar.jpg";
    url = "https://avatars.githubusercontent.com/u/30625554?v=4";
    sha256 = "0ppzb4b52089hhm39fvh8rc2rkqbxpc4zmyqdllnacyfwxng267y";
  };

  # The control-center widget can't decode SVG, so rasterize the logo.
  nixLogo = pkgs.runCommand "nix-snowflake.png" {nativeBuildInputs = [pkgs.librsvg];} ''
    rsvg-convert -w 256 -h 256 \
      ${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg \
      -o $out
  '';
in {
  config = lib.mkIf config.display.noctalia.enable {
    hm.programs.noctalia.settings = {
      shell = {
        avatar_path = "${avatar}";
        corner_radius_scale = 1.5;
        setup_wizard_enabled = false;
        clipboard_enabled = true;
        panel = {
          transparency_mode = "soft";
          clipboard_placement = "attached";
          open_near_click_control_center = true;
        };
        shadow.direction = "down";
      };

      theme = {
        mode = "dark";
        source = "custom";
        custom_palette = "nixus";
      };

      bar.main = {
        position = "right";
        capsule = false;
        background_opacity = config.colors.backgroundAlpha;
        margin_edge = 0;
        margin_ends = 0;
        radius = 0;
        start = ["control-center" "network" "bluetooth"];
        center = ["workspaces"];
        end = ["tray" "battery" "clock"];
      };

      dock = {
        enabled = true;
        auto_hide = true;
        reserve_space = false;
      };

      lockscreen.enabled = false;

      widget = {
        "control-center" = {
          custom_image = "${nixLogo}";
          scale = 1.3;
        };
        network.show_label = false;
        workspaces = {
          display = "none";
          empty_color = "outline";
        };
      };

      wallpaper = {
        enabled = true;
        directory = "${wallpaperDir}";
        # `directory` alone doesn't auto-pick a wallpaper on first run.
        default.path = "${wallpaper}";
      };

      osd.monitors = [mainMonitor];

      weather.enabled = true;
      location.auto_locate = true;
    };
  };
}
