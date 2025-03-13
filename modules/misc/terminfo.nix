{pkgs, ...}: {
  os.environment.systemPackages = builtins.map (x: x.terminfo) (with pkgs; [
    foot
    kitty
    wezterm
  ]);
}
