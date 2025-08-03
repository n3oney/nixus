{
  lib,
  pkgs,
  config,
  ...
}: let
  kalico = {
    stdenv,
    lib,
    fetchFromGitHub,
    python3,
    unstableGitUpdater,
    makeWrapper,
    writeShellScript,
    extraPythonPackages ? ps: [],
  }:
    stdenv.mkDerivation rec {
      pname = "klipper";
      version = "0.12.0-unstable-2025-07-08";

      src = fetchFromGitHub {
        owner = "KalicoCrew";
        repo = "kalico";
        rev = "91fd64805e59a92553c174bfd80eecece43095a1";
        sha256 = "sha256-EE+jV1JMQFOu4D8NlUZ9HquLiWud1stLw5vT+p5w3JM=";
      };
      sourceRoot = "${src.name}/klippy";

      # NB: This is needed for the postBuild step
      nativeBuildInputs = [
        (python3.withPackages (p: with p; [cffi]))
        makeWrapper
      ];

      buildInputs = [
        (python3.withPackages (
          p:
            with p;
              [
                can
                cffi
                pyserial
                greenlet
                jinja2
                markupsafe
                numpy
              ]
              ++ extraPythonPackages p
        ))
      ];

      # we need to run this to prebuild the chelper.
      postBuild = ''
        python ./chelper/__init__.py
      '';

      # Python 3 is already supported but shebangs aren't updated yet
      postPatch = ''
        # needed for cross compilation
        substituteInPlace ./chelper/__init__.py \
          --replace 'GCC_CMD = "gcc"' 'GCC_CMD = "${stdenv.cc.targetPrefix}cc"'
      '';

      pythonInterpreter =
        (python3.withPackages (
          p:
            with p; [
              numpy
              matplotlib
            ]
        )).interpreter;

      pythonScriptWrapper = writeShellScript pname ''
        ${pythonInterpreter} "@out@/lib/scripts/@script@" "$@"
      '';

      # NB: We don't move the main entry point into `/bin`, or even symlink it,
      # because it uses relative paths to find necessary modules. We could wrap but
      # this is used 99% of the time as a service, so it's not worth the effort.
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/klippy
        cp -r ./* $out/lib/klippy

        # Moonraker expects `config_examples` and `docs` to be available
        # under `klipper_path`
        cp -r $src/docs $out/lib/docs
        cp -r $src/config $out/lib/config
        cp -r $src/scripts $out/lib/scripts
        #cp -r $src/klippy $out/lib/klippy

        # Add version information. For the normal procedure see https://www.klipper3d.org/Packaging.html#versioning
        # This is done like this because scripts/make_version.py is not available when sourceRoot is set to "${src.name}/klippy"
        echo "${version}-NixOS" > $out/lib/klippy/.version

        mkdir -p $out/bin
        chmod 755 $out/lib/klippy/klippy.py
        makeWrapper $out/lib/klippy/klippy.py $out/bin/klippy --chdir $out/lib/klippy

        substitute "$pythonScriptWrapper" "$out/bin/klipper-calibrate-shaper" \
          --subst-var "out" \
          --subst-var-by "script" "calibrate_shaper.py"
        chmod 755 "$out/bin/klipper-calibrate-shaper"

        runHook postInstall
      '';

      passthru.updateScript = unstableGitUpdater {
        url = meta.homepage;
        tagPrefix = "v";
      };

      meta = with lib; {
        description = "Klipper 3D printer firmware";
        mainProgram = "klippy";
        homepage = "https://github.com/KevinOConnor/klipper";
        maintainers = with maintainers; [
          lovesegfault
          zhaofengli
          cab404
        ];
        platforms = platforms.linux;
        license = licenses.gpl3Only;
      };
    };

  cartographer-klipper = pkgs.fetchFromGitHub {
    owner = "Cartographer3D";
    repo = "cartographer-klipper";
    rev = "master";
    sha256 = "sha256-kcgF5Kz3ZX+lzo0B5DynPYrgR0OHneoSnZOpMUo0At4=";
  };

  kamp = pkgs.fetchFromGitHub {
    owner = "kyleisah";
    repo = "Klipper-Adaptive-Meshing-Purging";
    rev = "b0dad8ec9ee31cb644b94e39d4b8a8fb9d6c9ba0";
    sha256 = "sha256-05l1rXmjiI+wOj2vJQdMf/cwVUOyq5d21LZesSowuvc=";
  };
  package =
    (pkgs.callPackage kalico {
      extraPythonPackages = ps: [
        ps.numpy
        ps.matplotlib
        ps.scipy
      ];
    }).overrideAttrs
    (old: {
      installPhase =
        old.installPhase
        + ''
          cp ${cartographer-klipper}/idm.py $out/lib/klippy/extras/idm.py
          cp ${cartographer-klipper}/cartographer.py $out/lib/klippy/extras/cartographer.py
          cp ${cartographer-klipper}/scanner.py $out/lib/klippy/extras/scanner.py
        '';
    });
in {
  options.services.klipper.enable = lib.mkEnableOption "Klipper service";

  config.os = lib.mkIf config.services.klipper.enable {
    users.users.klipper = {
      isSystemUser = true;
      group = "klipper";
      description = "Klipper service user";
    };

    users.groups.klipper = {};

    security.rtkit.enable = true;

    services.klipper = {
      package =
        package;
      enable = true;
      user = "klipper";
      group = "klipper";
      configFile = "/etc/klipper/config/printer.cfg";
      configDir = "/etc/klipper/config";
      mutableConfig = true;
      logFile = "/var/log/klipper/klippy.log";
    };

    systemd.tmpfiles.settings."klippy-log"."/var/log/klipper".d = {
      mode = "0755";
      user = "klipper";
      group = "klipper";
    };

    services.moonraker = {
      enable = true;
      group = "klipper";
      stateDir = "/etc/klipper";
      settings = {
        file_manager.enable_object_processing = true;
        octoprint_compat = {};
        history = {};

        authorization = {
          trusted_clients = [
            "192.168.1.0/24"
          ];
        };
      };
    };

    environment.etc."klipper/config/KAMP" = {
      source = "${kamp}/Configuration";
      mode = "symlink";
      group = "klipper";
      user = "klipper";
    };
  };

  config.services.mainsail = lib.mkIf config.services.klipper.enable {
    hostName = "";
    port = 2137;
    enable = true;
  };
}
