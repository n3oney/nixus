{
  pkgs,
  lib,
  ...
}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;
  programs.opencode.enable = true;
  programs.claude-code = {
    enable = true;
    remoteControl = ["/etc/home-assistant"];
  };

  services.mcp.enable = true;

  programs.zoxide.enable = true;

  services.smarthome = {
    enable = true;
    home-assistant.host = "hass.max.local:80";
    wyoming.enable = false;
    otbr = {
      enable = true;
      backboneIf = "enp1s0";
    };
  };

  services.tailscale.enable = true;

  # services.librespot.enable = true;
  # services.klipper.enable = true;

  services.spoolman.enable = true;

  services.norish.enable = true;

  #services.sage.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
  ];

  os.environment.systemPackages = [pkgs.wget];
  os.boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
}
