{
  inputs,
  pkgs,
  ...
}: {
  os.environment = {
    systemPackages = [inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.default];
    sessionVariables.NH_FLAKE = "/home/neoney/nixus";
  };

  os.nix.settings = {
    extra-substituters = ["https://viperml.cachix.org"];
    extra-trusted-public-keys = ["viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="];
  };
}
