{
  config,
  inputs,
  lib,
  ...
}: let
  cfg = config.services.spoolman;

  pyproject-nix = import inputs.pyproject-nix {inherit lib;};
  uv2nix = import inputs.uv2nix {inherit pyproject-nix lib;};
  pyproject-build-systems = import inputs.pyproject-build-systems {
    inherit pyproject-nix uv2nix lib;
  };
in {
  options.services.spoolman = {
    enable = lib.mkEnableOption "Spoolman, a filament spool inventory management system.";

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Open the appropriate ports in the firewall for spoolman.
      '';
    };

    listen = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "The IP address to bind the spoolman server to.";
    };
  };

  config.os = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (_final: prev: let
        version = "0.23.1";

        rawSrc = prev.fetchFromGitHub {
          owner = "Donkie";
          repo = "Spoolman";
          tag = "v${version}";
          hash = "sha256-Oa/cNmpc0hWRf0EQI5aXIE/p9//Sos5Nj3QFEjKgj5o=";
        };

        src = prev.runCommand "spoolman-src-${version}" {} ''
          cp -r ${rawSrc} $out
          chmod -R +w $out
          cat >> $out/pyproject.toml <<'EOF'

          [build-system]
          requires = ["setuptools"]
          build-backend = "setuptools.build_meta"

          [tool.setuptools]
          packages = ["spoolman"]
          EOF
        '';

        python = prev.python312;

        workspace = uv2nix.lib.workspace.loadWorkspace {workspaceRoot = src;};

        overlay = workspace.mkPyprojectOverlay {
          sourcePreference = "wheel";
        };

        pythonSet =
          (prev.callPackage pyproject-nix.build.packages {inherit python;})
          .overrideScope (lib.composeManyExtensions [
            pyproject-build-systems.overlays.default
            overlay
          ]);

        venv = pythonSet.mkVirtualEnv "spoolman-env" workspace.deps.default;

        frontend = prev.buildNpmPackage {
          pname = "spoolman-frontend";
          inherit version;
          src = "${rawSrc}/client";
          npmDepsHash = "sha256-8ojD7xMxRE9+b4O7vJdwKwrg8aYukYc3l+LF5enKFgA=";
          VITE_APIURL = "/api/v1";
          installPhase = "cp -r dist $out";
        };

        start_script = prev.writeShellScript "start-spoolman" ''
          ${venv}/bin/uvicorn "$@" spoolman.main:app
        '';
      in {
        spoolman = prev.stdenv.mkDerivation {
          pname = "spoolman";
          inherit version src;

          nativeBuildInputs = [prev.makeWrapper];

          dontBuild = true;
          dontConfigure = true;

          installPhase = ''
            runHook preInstall

            mkdir -p $out/runpath/client/dist $out/bin
            cp -r ${src}/* $out/runpath
            cp -r ${frontend}/* $out/runpath/client/dist

            makeWrapper ${start_script} $out/bin/spoolman \
              --chdir $out/runpath \
              --prefix PATH : "${venv}/bin"

            runHook postInstall
          '';

          meta = {
            description = "Spoolman server";
            homepage = "https://github.com/Donkie/Spoolman";
            license = lib.licenses.mit;
            mainProgram = "spoolman";
          };
        };
      })
    ];

    services.spoolman = {
      enable = true;
      inherit (cfg) openFirewall listen;
    };
  };
}
