{
  lib,
  fetchFromGitHub,
  rustPlatform,
  libusb,
}:
rustPlatform.buildRustPackage rec {
  pname = "mxw";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "dxbednarczyk";
    repo = pname;
    rev = "dacf27f4f57f5f04f08afeb26186c350ddf5f79f";
    hash = "";
  };

  cargoHash = "";

  buildInputs = [libusb];

  meta = with lib; {
    description = "A fast line-oriented regex search tool, similar to ag and ack";
    homepage = "https://github.com/BurntSushi/ripgrep";
    license = licenses.unlicense;
    maintainers = [];
  };
}
