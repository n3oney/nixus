# opencode-gemini-auth packaged from a PR that fixes gemini 3
{pkgs, ...}:
pkgs.stdenv.mkDerivation rec {
  pname = "opencode-gemini-auth";
  version = "1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "JoshuaKirby88";
    repo = "opencode-gemini-auth";
    rev = "e07b1d7da4ff6ccac54cecee4f8b75f5fed7f0d2";
    hash = "sha256-xietlS7lGZpaqOvGE3Wot/fKZUkBDM+eYDV52AGahn4=";
  };

  nativeBuildInputs = [pkgs.bun];

  bunDeps = pkgs.stdenv.mkDerivation {
    name = "${pname}-bun-deps";
    inherit src;
    nativeBuildInputs = [pkgs.bun];

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-tFuqIZ+B9XMX59dZX2u+KxP0TYZLg7/8JMOpXdjAi+Q=";

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

    runHook postBuild
  '';

  installPhase = ''
    mkdir -p $out

    cp -r * $out/
  '';
}
