{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libusb,
  pkg-config,
}:
rustPlatform.buildRustPackage rec {
  pname = "mxw";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dxbednarczyk";
    repo = pname;
    rev = "dacf27f4f57f5f04f08afeb26186c350ddf5f79f";
    hash = "sha256-hVJiKa4ODnglR6lG8NXxaEjCqsKXxrHNv7i8XsZd+T8=";
  };

  cargoHash = "sha256-2cE8E26LOeqiLEh/SEKKDJRni/5e0HG2yqrKOC3s2mg=";

  buildInputs = [libusb];
  nativeBuildInputs = [pkg-config];

  meta = with lib; {
    description = ''
      Cross platform CLI tool for Glorious' wireless mice.

      Originally reverse engineered using USB packet logs sniffed with
      WireShark and USBPcap, as well as a decompilation of the official
      Windows program (Glorious Core).
    '';
    homepage = "https://github.com/${src.owner}/${src.repo}";
    license = licenses.unfree;
    maintainers = [];
  };
}
