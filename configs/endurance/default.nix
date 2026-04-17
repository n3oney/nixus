{
  pkgs,
  lib,
  ...
}: {
  users.main = "neoney";

  agenix.enable = true;

  programs.btop.enable = true;
  programs.claude-code = {
    enable = true;
    remoteControl = ["/etc/home-assistant"];
  };

  services.mcp = {
    enable = true;
    servers = ["homeAssistant"];
  };

  programs.zoxide.enable = true;

  services.smarthome = {
    enable = true;
    home-assistant.host = "hass.endurance.local:80";
    wyoming.enable = true;
    pivo.enable = true;
    otbr = {
      enable = true;
      backboneIf = "enp4s0";
    };
  };

  services.tailscale.enable = true;

  # services.librespot.enable = true;

  services.spoolman.enable = true;

  services.norish.enable = true;

  services.cyan-skillfish-governor.enable = true;

  os.hardware.fancontrol = {
    enable = true;
    config = ''
      INTERVAL=5
      DEVPATH=hwmon0=devices/pci0000:00/0000:00:08.1/0000:01:00.0 hwmon2=devices/platform/nct6687.2592
      DEVNAME=hwmon0=amdgpu hwmon2=nct6686
      FCTEMPS=hwmon2/pwm2=hwmon0/temp1_input
      FCFANS=hwmon2/pwm2=hwmon2/fan2_input
      MINTEMP=hwmon2/pwm2=60
      MAXTEMP=hwmon2/pwm2=80
      MINSTART=hwmon2/pwm2=120
      MINSTOP=hwmon2/pwm2=60
      MINPWM=hwmon2/pwm2=50
      MAXPWM=hwmon2/pwm2=255
    '';
  };

  services.whisper-cpp = {
    enable = true;
    model = "/var/lib/whisper-cpp/ggml-large-v3-turbo.bin";
  };

  services.llama-cpp.instances.chat = {
    host = "0.0.0.0";
    openFirewall = true;
    contextSize = 16384;
    model = "/var/lib/llama-cpp-chat/Bielik-11B-v3.0-Instruct.Q5_K_M.gguf";
    # mmproj = "/var/lib/llama-cpp-chat/mmproj-gemma-4-E4B-it-F16.gguf";
    chatTemplate = ../../modules/services/llm/bielik-chat-template.jinja;
    extraArgs = ["--temp 0.1"];
  };

  services.omnivoice = {
    enable = true;
    host = "0.0.0.0";
    openFirewall = true;
    model = "/var/lib/omnivoice/omnivoice-base-Q4_K_M.gguf";
    codec = "/var/lib/omnivoice/omnivoice-tokenizer-Q4_K_M.gguf";
    defaultInstruct = "female, young adult, moderate pitch";
  };

  #services.sage.enable = true;

  h.packages = with pkgs; [
    ripgrep
  ];

  os.networking.hosts = {
    "192.168.1.30" = ["miko"];
  };
  os.environment.systemPackages = [pkgs.wget];
  os.boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    kernelPatches = [
      {
        name = "bc250-40cu-unlock";
        patch = ../../hosts/endurance/bc250-40cu-amdgpu.patch;
      }
      {
        name = "bc250-freq-range";
        patch = ../../hosts/endurance/bc250-freq-range.patch;
      }
      {
        name = "bc260-disable-kiq";
        patch = ../../hosts/endurance/bc250-disable-kiq.patch;
      }
    ];
    kernelParams = [
      "amdgpu.bc250_cc_write_mode=3"

      # Disable inherited panic-on-soft-issue policies
      # so KIQ wedges don't take down the whole machine
      "softlockup_panic=0"
      "hung_task_panic=0"

      # Cleaner amdgpu defaults
      "amdgpu.vm_update_mode=0" # was 3, was forcing redundant CPU+SDMA VM updates
      "amdgpu.noretry=1" # disable XNACK retry, removes one TLB-flush trigger
    ];
  };
}
