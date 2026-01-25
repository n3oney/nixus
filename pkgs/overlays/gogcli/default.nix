{
  buildGoModule,
  fetchFromGitHub,
  lib,
  ...
}:
buildGoModule rec {
  pname = "gogcli";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "steipete";
    repo = "gogcli";
    rev = "v${version}";
    sha256 = "sha256-DXRw5jf/5fC8rgwLIy5m9qkxy3zQNrUpVG5C0RV7zKM=";
  };

  vendorHash = "sha256-nig3GI7eM1XRtIoAh1qH+9PxPPGynl01dCZ2ppyhmzU=";

  ldflags = [
    "-X github.com/steipete/gogcli/internal/cmd.version=${version}"
    "-X github.com/steipete/gogcli/internal/cmd.commit=nix-${version}"
    "-X github.com/steipete/gogcli/internal/cmd.date=1970-01-01T00:00:00Z"
  ];

  subPackages = ["cmd/gog"];

  meta = with lib; {
    description = "Google Suite CLI: Gmail, GCal, GDrive, GContacts";
    homepage = "https://github.com/steipete/gogcli";
    license = licenses.mit;
    mainProgram = "gog";
    platforms = platforms.linux ++ platforms.darwin;
  };
}
