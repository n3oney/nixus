{
  config,
  lib,
  inputs,
  ...
}: {
  options.nur.enable = lib.mkEnableOption "NUR";

  config = lib.mkMerge [
    (lib.mkIf config.nur.enable {
      os.nixpkgs.overlays = [inputs.nur.overlays.default];
    })
  ];
}
