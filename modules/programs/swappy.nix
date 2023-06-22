{
  pkgs,
  config,
  lib,
  ...
}: {
  options.programs.swappy.enable = lib.mkEnableOption "swappy";

  config.hm.home.packages = lib.mkIf config.programs.swappy.enable [
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
}
