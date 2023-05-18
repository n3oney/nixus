{
  system = _: {
    hardware.gpgSmartcards.enable = true;
  };

  home = _: {
    programs.git.signing = {
      key = "0x1261173A01E10298";
      signByDefault = true;
    };

    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      pinentryFlavor = "gnome3";
      enableSshSupport = true;
      sshKeys = ["B390FD9142AF0954054B0B3C312763C295DA2E65"];
    };

    programs.ssh.extraConfig = ''
      AddKeysToAgent yes
    '';

    programs.gpg = {
      enable = true;
      publicKeys = [
        {
          text = ''
            -----BEGIN PGP PUBLIC KEY BLOCK-----
            Comment: Hostname:
            Version: Hockeypuck 2.1.0-207-gbc96f7e

            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
            =oQ/1
            -----END PGP PUBLIC KEY BLOCK-----
          '';
        }
      ];
    };
  };
}
