{
  config,
  lib,
  pkgs,
  ...
}: {
  options.gpg.enable = lib.mkEnableOption "gpg";

  config = lib.mkIf config.gpg.enable {
    os = {
      services.pcscd.enable = true;
      hardware.gpgSmartcards.enable = true;
    };

    hm = {
      programs.git.signing = {
        key = "0x1261173A01E10298";
        signByDefault = true;
      };

      services.gpg-agent = {
        enable = true;
        enableFishIntegration = true;
        pinentryPackage = pkgs.pinentry-gnome3;
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

              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
              =NUQ7
              -----END PGP PUBLIC KEY BLOCK-----
            '';
          }
        ];
      };
    };
  };
}
