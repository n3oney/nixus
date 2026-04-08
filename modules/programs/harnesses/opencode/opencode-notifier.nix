{
  pkgs,
  src,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "@mohak34/opencode-notifier";
  version = "0.1.32";

  inherit src;

  nativeBuildInputs = [pkgs.bun];

  bunDeps = pkgs.stdenv.mkDerivation {
    name = "${pname}-bun-deps";
    inherit src;
    nativeBuildInputs = [pkgs.bun];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-ZgLUzS+8dOUDLURANfIFLugciwo/OxNbjUoTK6PEqjU=";

    dontConfigure = true;

    buildPhase = ''
      export HOME=$TMPDIR
      bun install --frozen-lockfile --no-progress
    '';

    installPhase = ''
      mkdir -p $out
      cp -r node_modules $out/
    '';
  };

  buildPhase = ''
    runHook preBuild

    ln -s ${bunDeps}/node_modules node_modules
    export HOME=$TMPDIR
    bun build src/index.ts --outdir dist --target node --external node-notifier

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out

    cp -r * $out/
  '';
}
