{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "zed-plex-mono";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "zed-industries";
    repo = "zed-fonts";
    rev = "0e344bf9229e3ca1b63ae8331524152b3710851d";
    hash = "sha256-FerwyiD8L3yJ/f4JTBwuBAj8Ctl9n6k4hH4A4xe5FiU=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp zed-plex/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = "Zed Plex Mono is a fork of IBM Plex with ligatures manually added.";
    platforms = platforms.all;
  };
}
