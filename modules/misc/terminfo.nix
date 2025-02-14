{pkgs, ...}: {
  os.environment.systemPackages = builtins.map (x: x.terminfo) (with pkgs; [
    alacritty
    foot
    kitty
    wezterm
    ghostty
  ]);
}
