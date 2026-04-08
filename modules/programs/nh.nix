{
  inputs,
  pkgs,
  ...
}: {
  os.environment = {
    systemPackages = [
      (inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace crates/nh-remote/src/remote.rs \
              --replace-quiet '.args(["copy", "--to"])' '.args(["copy", "--no-check-sigs", "--to"])' \
              --replace-quiet '.args(["copy", "--from"])' '.args(["copy", "--no-check-sigs", "--from"])' \
              --replace-quiet 'format!("ssh://{}", host.ssh_host())' 'format!("ssh-ng://{}", host.ssh_host())' \
              --replace-quiet 'format!("ssh://{}", from_host.ssh_host())' 'format!("ssh-ng://{}", from_host.ssh_host())' \
              --replace-quiet 'format!("ssh://{}", to_host.ssh_host())' 'format!("ssh-ng://{}", to_host.ssh_host())'
          '';
      }))
    ];
    sessionVariables.NH_FLAKE = "/home/neoney/nixus";
  };

  os.nix.settings = {
    extra-substituters = ["https://viperml.cachix.org"];
    extra-trusted-public-keys = ["viperml.cachix.org-1:qZhKBMTfmcLL+OG6fj/hzsMEedgKvZVFRRAhq7j8Vh8="];
  };
}
