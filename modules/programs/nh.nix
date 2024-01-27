{
  inputs,
  lib,
  pkgs,
  ...
}: {
  os.environment = {
    systemPackages = [inputs.nh.packages.${pkgs.system}.default];
    sessionVariables.FLAKE = "/home/neoney/nixus";
  };

  os.nix.settings = {
    extra-substituters = ["https://viperml.cachix.org"];
    extra-trusted-public-keys = ["viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="];
  };
}
