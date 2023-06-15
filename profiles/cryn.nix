mkSystem: let
  username = "neoney";
in
  mkSystem {
    inherit username;
    args = {};
  } {
    configs = cfgs:
      with cfgs; [
        btop
        colors
        fish
        git
        helix
        lemmy
        nix
        terminfo
        pkgs
        ssh
        starship
      ];

    system = {pkgs, ...}: {
      time.timeZone = "Europe/Warsaw";
      i18n.defaultLocale = "en_US.UTF-8";

      programs.dconf.enable = true;

      environment.systemPackages = with pkgs; [
        wget
        ripgrep
      ];
    };
  }
