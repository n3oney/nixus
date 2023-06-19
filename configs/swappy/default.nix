{
  home = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [
      (pkgs.swappy.overrideAttrs (old: {
        patches = [
          (pkgs.fetchpatch
            {
              url = "https://patch-diff.githubusercontent.com/raw/jtheoof/swappy/pull/151.patch";
              hash = "sha256-j7AyhEWoAoJhWjksPix36HpcuGDCFfk+/bV1CA2jgyM=";
            })
        ];
      }))
    ];
  };
}
