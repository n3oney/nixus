{
  inputs.impermanence.url = "github:nix-community/impermanence";

  add = {impermanence, ...}: {
    modules = [impermanence.nixosModules.default];
    homeModules = [impermanence.nixosModules.home-manager.impermanence];
  };

  system = _: {
    environment.persistence."/persist" = {
      directories = ["/etc/nixos" "/etc/NetworkManager" "/var/log" "/var/lib" "/etc/nix" "/etc/ssh"];
      files = ["/etc/machine-id"];
    };

    programs.fuse.userAllowOther = true;
  };

  home = _: {
    home.persistence."/persist/home/neoney" = {
      directories = [
        "nixus"
        "Downloads"
        "code"
        "Documents"
        "Kooha"
        "Music"
        ".ssh"
        ".local/share/direnv"
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        ".steam"
        ".gnupg"
        ".config/WebCord"
      ];
      files = [
        ".cache/anyrun-ha-assist.sqlite3"
      ];
      allowOther = true;
    };
  };
}
