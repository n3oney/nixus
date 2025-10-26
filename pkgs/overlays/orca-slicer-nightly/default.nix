{
  orca-slicer,
  fetchFromGitHub,
  ...
}:
orca-slicer.overrideAttrs (old: {
  pname = "orca-slicer-nightly";
  version = "2.3.1-unstable-2025-10-26";

  src = fetchFromGitHub {
    owner = "SoftFever";
    repo = "OrcaSlicer";
    rev = "ce854fa3de9b30b38e967f6e36be5e6fabed9c37";
    hash = "sha256-Rfd8+1pBWixC0sQzOq9KIMKoZOK+tIvYP/M3D1pkjAc=";
  };

  meta =
    old.meta
    // {
      description = "Orca Slicer nightly build";
    };
})
