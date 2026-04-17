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

  # services.mcp.enable = true;

  programs.zoxide.enable = true;

  services.smarthome = {
    enable = true;
    home-assistant.host = "hass.endurance.local:80";
    wyoming.enable = true;
    otbr = {
      enable = true;
      backboneIf = "enp4s0";
    };
  };

  services.tailscale.enable = true;

  # services.librespot.enable = true;
  # services.klipper.enable = true;

  services.spoolman.enable = true;

  services.norish.enable = true;

  services.cyan-skillfish-governor.enable = true;

  services.whisper-cpp = {
    enable = true;
    model = "/var/lib/whisper-cpp/ggml-large-v3-turbo.bin";
  };

  services.llama-cpp = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    contextSize = 65536;
    model = "/var/lib/llama-cpp/Qwen3.5-9B-Q6_K.gguf";
    # mmproj = "/var/lib/llama-cpp/mmproj-gemma-4-E4B-it-F16.gguf";
  };

  #services.sage.enable = true;

  hm.home.packages = with pkgs; [
    ripgrep
  ];

  os.environment.systemPackages = [pkgs.wget];
  os.boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
}
