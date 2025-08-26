{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libusb1,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "mxw";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dxbednarczyk";
    repo = pname;
    rev = "2e493b5abccb8ed22f4b814ca1bf59bfe16c9c78";
    hash = "sha256-IBDxn64XQsvg+C+9rfn71zzlOpgfcl/7PPFNnRyazP8=";
  };

  cargoHash = "sha256-xiLpV/nC+x1VAh9X3r3gxBEqcWZAcTp52SuNNjg/ruU=";

  buildInputs = [libusb1];
  nativeBuildInputs = [pkg-config];

  meta = with lib; {
    description = ''
      Cross platform CLI tool for Glorious' wireless mice.

      Originally reverse engineered using USB packet logs sniffed with
      WireShark and USBPcap, as well as a decompilation of the official
      Windows program (Glorious Core).
    '';
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = [licenses.mit licenses.gpl3];
    maintainers = [];
  };
}
