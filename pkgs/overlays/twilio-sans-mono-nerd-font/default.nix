{
  lib,
  stdenvNoCC,
  fetchzip,
  nerd-font-patcher,
}:
stdenvNoCC.mkDerivation {
  pname = "twilio-sans-mono-nerd-font";
  version = "unstable-2022-11-17";

  src = fetchzip {
    url = "https://github.com/twilio/twilio-sans-mono/raw/6bb29c96842f19a533401e6266fdfdd813dcf3e4/Twilio-Sans-Mono.zip";
    hash = "sha256-cUFAsB4pWsXhPvbuiFqXARTMYW+63rEGTwa8RNvuU84=";
  };

  nativeBuildInputs = [nerd-font-patcher];

  buildPhase = ''
    find -name \*.ttf -execdir nerd-font-patcher -c {} \;
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    cp **/*.ttf $out/share/fonts/truetype

    runHook postInstall
  '';

  meta = with lib; {
    description = " Twilio Sans Mono is a beautiful and extensive open source programming font";
    platforms = platforms.all;
    license = licenses.ofl;
    maintainers = [maintainers.n3oney];
    homepage = "https://github.com/twilio/twilio-sans-mono";
  };
}
