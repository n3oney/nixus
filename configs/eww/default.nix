{
  inputs = {
    rust-overlay.url = "github:oxalica/rust-overlay";
    eww = {
      url = "github:elkowar/eww";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
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
      gcc-unwrapped
      socat
      pulseaudio
      jaq
      pamixer
    ];
  };
}
