{
  lib,
  pkgs,
  config,
  ...
}: let
  buildFirefoxXpiAddon = lib.makeOverridable ({
    stdenv ? pkgs.stdenv,
    fetchurl ? pkgs.fetchurl,
    pname,
    version,
    addonId,
    src,
    zip ? pkgs.zip,
    ...
  }:
    stdenv.mkDerivation {
      inherit src;
      name = "${pname}-${version}";
      preferLocalBuild = true;
      allowSubstitutes = true;
      buildInputs = [zip];
      buildCommand = ''
        dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
        mkdir -p "$dst"

        cd "$src"
        zip -r "$dst/${addonId}.zip" *

        install -v -m644 "$dst/${addonId}.zip" "$dst/${addonId}.xpi"

        rm "$dst/${addonId}.zip"
      '';
    });

  external-tabs = buildFirefoxXpiAddon {
    pname = "external-tabs";
    version = "1.0.0";
    addonId = "external-tabs@neoney.dev";
    src = ./external-tabs;
  };
in {
  options.programs.cinny.enable = lib.mkEnableOption "Cinny";

  config.os = lib.mkIf config.programs.cinny.enable {
    services.caddy.enable = true;
    services.caddy.virtualHosts."cinny.localhost:80" = {
      extraConfig = ''
        root * ${pkgs.cinny}
        file_server

        @index {
          not path /index.html
          not path /public/*
          not path /assets/*

          not path /config.json

          not path /manifest.json

          not path /pdf.worker.min.js
          not path /olm.wasm

          path /*
        }

        rewrite /*/olm.wasm /olm.wasm
        rewrite @index /index.html
      '';
    };
  };

  config.hm = lib.mkIf config.programs.cinny.enable {
    programs.firefox.nativeMessagingHosts = [
      (pkgs.writeTextFile {
        destination = "/lib/mozilla/native-messaging-hosts/external_tabs.json";
        name = "external_tabs.json";
        text = builtins.toJSON {
          name = "external_tabs";
          description = "Host to open tabs with xdg-open";
          path = pkgs.writeScript "external_tabs" ''
            #!${lib.getExe pkgs.python3}
                    
            import sys
            import struct
            import subprocess
            import json

            # Read a message from stdin and decode it.
            def getMessage():
                rawLength = sys.stdin.buffer.read(4)
                if len(rawLength) == 0:
                    sys.exit(0)
                messageLength = struct.unpack('@I', rawLength)[0]
                message = sys.stdin.buffer.read(messageLength).decode('utf-8')
                return json.loads(message)

            while True:
                receivedMessage = getMessage()
                if receivedMessage:
                    f = open("/tmp/output.txt", "a")
                    f.write(receivedMessage + "\n")
                    f.close()

                    subprocess.run(["xdg-open", receivedMessage])'';
          type = "stdio";
          allowed_extensions = ["external-tabs@neoney.dev"];
        };
      })
    ];

    programs.firefox.profiles."nixus.cinny" = {
      name = "cinny";
      id = 1;
      extensions = [external-tabs];
      settings = {
        "xpinstall.signatures.required" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      userChrome = ''
        #navigator-toolbox {
          position: fixed;
          top: -1000px;
          left: -1000px;
        }
      '';
    };

    home.packages = [
      (pkgs.writeShellScriptBin "cinny" "firefox -P \"cinny\" \"http://cinny.localhost\" --no-remote --name=cinny")
    ];

    xdg.desktopEntries.cinny = {
      name = "Cinny";
      comment = "Yet another matrix client";
      exec = "cinny";
      icon = ./icon.svg;
      type = "Application";
      terminal = false;
    };
  };
}
