{
  inputs = {
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  home = {
    pkgs,
    inputs,
    ...
  }: {
    programs.eww.enable = true;
    programs.eww.package = inputs.eww.packages.${pkgs.system}.eww-wayland;
    programs.eww.configDir = ./config;

    home.packages = with pkgs; [
      socat
      pulseaudio
      jaq
      pamixer
    ];
  };
}
