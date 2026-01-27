{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm,
  nodejs,
  makeBinaryWrapper,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "bird";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "bird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4bXxaHCislWgOITqoWWc+MffhmhUdzuk9CBjKA24J5s=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    hash = "sha256-KhRDOAQTP+GIgcoaI0urNfoygT3/HUvRfHmqpm/r4KI=";
    fetcherVersion = 2;
  };

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeBinaryWrapper
  ];

  buildPhase = ''
    runHook preBuild
    pnpm run build:dist
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/@steipete/bird
    cp -r dist $out/lib/node_modules/@steipete/bird/
    cp package.json $out/lib/node_modules/@steipete/bird/

    # Install production dependencies
    rm -rf node_modules
    pnpm install --offline --prod --frozen-lockfile
    mv node_modules $out/lib/node_modules/@steipete/bird/

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/bird \
      --add-flags "$out/lib/node_modules/@steipete/bird/dist/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "CLI tool for tweeting and replying via Twitter/X GraphQL API";
    homepage = "https://github.com/steipete/bird";
    license = lib.licenses.mit;
    mainProgram = "bird";
    platforms = lib.platforms.unix;
  };
})
