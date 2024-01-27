{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule {
  pname = "leveldb-cli";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "cions";
    repo = "leveldb-cli";
    rev = "b5d2fea43b7582cb8eeff493b709da7be4bcf5ce";
    sha256 = "Hg8QUx2Du/ye3/gEDtx2QoOgahJy/VunEwmlKhVdNgA=";
  };

  vendorHash = "sha256-zJc7bzd/NeMuouLqhoOWG0ZuFxpUiPnAZRvWc/OKllU=";

  postInstall = ''
    mv $out/bin/leveldb $out/bin/leveldb-cli
  '';

  meta = with lib; {
    description = "A command-line interface for LevelDB";
    homepage = "https://github.com/cions/leveldb-cli";
    license = licenses.mit;
  };
}
