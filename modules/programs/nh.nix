{
  inputs,
  pkgs,
  ...
}: {
  os.environment = {
    systemPackages = [
      (inputs.nh.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
        # Note: ssh-ng:// breaks here because nix injects
        # `-oLocalCommand="echo started"` as a readiness signal, and nh
        # pre-establishes an SSH ControlMaster — the reused master sends the
        # LocalCommand output on the same stdout as the binary daemon
        # protocol, yielding `protocol mismatch, got 'started'`. Stick with
        # upstream ssh:// (legacy nix-store --serve), which doesn't do that.
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace crates/nh-remote/src/remote.rs \
              --replace-quiet '.args(["copy", "--to"])' '.args(["copy", "--no-check-sigs", "--to"])' \
              --replace-quiet '.args(["copy", "--from"])' '.args(["copy", "--no-check-sigs", "--from"])'
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
