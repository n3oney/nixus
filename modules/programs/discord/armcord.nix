{
  lib,
  config,
  ...
}: {
  options.programs.discord.armcordSettings = lib.mkOption {
    default = {
      windowStyle = "transparent";
      channel = "canary";
      armcordCSP = true;
      minimizeToTray = true;
      automaticPatches = false;
      keybinds = [];
      alternativePaste = false;
      multiInstance = false;
      mods = "vencord";
      spellcheck = true;
      performanceMode = "performance";
      skipSplash = true;
      inviteWebsocket = true;
      startMinimized = false;
      dynamicIcon = false;
      tray = true;
      customJsBundle = "https://armcord.app/placeholder.js";
      customCssBundle = "https://armcord.app/placeholder.css";
      disableAutogain = false;
      useLegacyCapturer = false;
      mobileMode = false;
      trayIcon = "default";
      doneSetup = true;
      clientName = "ArmCord";
      customIcon = "${config.programs.discord.package}/opt/ArmCord/resources/app.asar/assets/desktop.png";
    };
  };
}
