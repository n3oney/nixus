{
  config,
  lib,
  inputs,
  ...
}: {
  options.nur.enable = lib.mkEnableOption "NUR";

  config = lib.mkMerge [
    {
      inputs = {
        nur.url = "github:nix-community/NUR";
      };
    }
    (lib.mkIf config.nur.enable {
      os.nixpkgs.overlays = [inputs.nur.overlay];
    })
  ];
}
