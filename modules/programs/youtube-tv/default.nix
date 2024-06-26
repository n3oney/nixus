{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.programs.youtube-tv;
  inherit (lib) mkEnableOption mkOption types mkIf;
in {
  options.programs.youtube-tv = {
    enable = mkEnableOption "youtube-tv";
    audioSink = mkOption {
      type = types.nullOr types.str;
      default = null;
    };
  };

  config.hm = mkIf cfg.enable (let
    buildFirefoxXpiAddon = lib.makeOverridable ({
      stdenv ? pkgs.stdenv,
      fetchurl ? pkgs.fetchurl,
      pname,
      version,
      addonId,
      url,
      sha256,
      ...
    }:
      stdenv.mkDerivation {
        name = "${pname}-${version}";
        src = fetchurl {inherit url sha256;};
        preferLocalBuild = true;
        allowSubstitutes = true;
        buildCommand = ''
          dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
          mkdir -p "$dst"
          install -v -m644 "$src" "$dst/${addonId}.xpi"
        '';
      });

    extra-addons = {
      youtube-for-tv = buildFirefoxXpiAddon {
        pname = "youtube-for-tv";
        version = "0.0.3";
        addonId = "{d2bcedce-889b-4d53-8ce9-493d8f78612a}";
        url = "https://addons.mozilla.org/firefox/downloads/file/3420768/youtube_for_tv-0.0.3.xpi";
        sha256 = "Xfa7cB4D0Iyfex5y9/jRR93gUkziaIyjqMT0LIOhT6o=";
      };
    };
  in {
    programs.firefox.profiles.youtubeTV = {
      name = "YouTube TV";
      id = 2;
      extensions = with pkgs.nur.repos.rycee.firefox-addons;
      with extra-addons; [
        ublock-origin
        sponsorblock
        youtube-for-tv
      ];
    };

    xdg.desktopEntries.youtube-tv = {
      name = "Youtube TV";
      comment = "Youtube for TV, on Desktop.";
      exec = "${
        if cfg.audioSink != null
        then "env PULSE_SINK=${cfg.audioSink} "
        else ""
      }firefox --kiosk -P \"YouTube TV\" \"https://youtube.com/tv\"";
      icon = ./icon.svg;
      type = "Application";
      terminal = false;
    };
  });
}
