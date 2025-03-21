{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.firefox.enable = lib.mkEnableOption "firefox";

  config.impermanence.userDirs = lib.mkIf config.programs.firefox.enable [".mozilla"];

  config.hm = lib.mkIf config.programs.firefox.enable (let
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
      vencord = buildFirefoxXpiAddon {
        pname = "vencord";
        version = "1.2.0";
        addonId = "vencord-firefox@vendicated.dev";
        url = "https://addons.mozilla.org/firefox/downloads/file/4104446/vencord_web-1.2.0.xpi";
        sha256 = "jm1Lpu39POCVdD7KS7iqBiMN73i0MaVpkB51hldIak8=";
      };
      ctrl-number = buildFirefoxXpiAddon {
        pname = "ctrl-number";
        version = "1.0.1";
        addonId = "{84601290-bec9-494a-b11c-1baa897a9683}";
        url = "https://addons.mozilla.org/firefox/downloads/file/3525464/ctrl_number_to_switch_tabs-1.0.1.xpi";
        sha256 = "zjGyU+d8BkY0esCoD0Ow0W1sjIlvrMOx42DcwL1s4Pc=";
      };
      catppuccin = buildFirefoxXpiAddon {
        pname = "catppuccin";
        version = "2.0";
        addonId = "{e554e180-24a4-40a2-911d-bf48d5b1629c}";
        url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_macchiato_pink.xpi";
        sha256 = "4qyNw3VLEMnEQq1MYaFljHxJfYwzKXRdLQxqkLO8Iqk=";
      };
      jiffy-reader = buildFirefoxXpiAddon {
        pname = "jiffy-reader";
        version = "1.0.10.2";
        addonId = "{93f81583-1fd4-45cc-bff4-abba952167bb}";
        url = "https://addons.mozilla.org/firefox/downloads/file/4123246/jiffy_reader-1.0.10.2.xpi";
        sha256 = "sha256-LLjbDnX8307yK1i3PSIxKTPcOB8DOzXOgOBllIeAD/w=";
      };
    };
  in {
    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {
        extraPolicies = {
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          DisableFirefoxAccounts = true;

          PasswordManagerEnabled = false;

          PromptForDownloadLocation = true;
        };
      };
      profiles."nixus.dev-edition-default" = {
        id = 0;
        name = "dev-edition-default";
        isDefault = true;
        settings = {
          "middlemouse.paste" = false;
        };
        extensions = with pkgs.nur.repos.rycee.firefox-addons;
        with extra-addons; [
          bitwarden
          ctrl-number
          stylus
          refined-github
          ublock-origin
          sponsorblock
          catppuccin
          youtube-shorts-block
          jiffy-reader
          react-devtools
        ];
      };
    };
  });
}
