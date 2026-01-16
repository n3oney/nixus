# opencode-anthropic-auth with the index file swapped
{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "opencode-anthropic-auth";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "anomalyco";
    repo = "opencode-anthropic-auth";
    rev = "8872d7de77d6a000333a54884db9ae12450e2f21";
    hash = "sha256-Tv3auytYaB01hKSf+2nXX85siLcvj25aiOzM8PnqA88=";
  };

  nativeBuildInputs = [pkgs.bun];

  bunDeps = pkgs.stdenv.mkDerivation {
    name = "${pname}-bun-deps";
    inherit src;
    nativeBuildInputs = [pkgs.bun];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-MT6tYPl2gcR8oiB7oG4UecH+F4Fx6DaHCbbKynYnqcY=";

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

    rm index.mjs
    cp ${./anthropic-auth-index.mjs} index.mjs

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out

    cp -r * $out/
  '';
}
