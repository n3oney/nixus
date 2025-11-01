{
  lib,
  config,
  pkgs,
  hmConfig,
  ...
}: {
  options.programs.gaming.alvr.enable = lib.mkEnableOption "ALVR";

  config = lib.mkIf config.programs.gaming.alvr.enable {
    os = {
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      boot.kernelPatches = [
        {
          name = "amdgpu-ignore-ctx-privileges";
          patch = pkgs.fetchpatch {
            name = "cap_sys_nice_begone.patch";
            url = "https://github.com/Frogging-Family/community-patches/raw/master/linux61-tkg/cap_sys_nice_begone.mypatch";
            hash = "sha256-Y3a0+x2xvHsfLax/uwycdJf3xLxvVfkfDVqjkxNaYEo=";
          };
        }
      ];
    };

    impermanence.userFiles = [".config/alvr/session.json"];

    hm.xdg.configFile."openxr/1/active_runtime.json".source = hmConfig.lib.file.mkOutOfStoreSymlink "/home/neoney/.local/share/Steam/steamapps/common/SteamVR/steamxr_linux64.json";

    hm.xdg.desktopEntries = {
      valve-URI-steamvr = {
        name = "URI-steamvr";
        comment = "URI handler for steamvr://";
        exec = "/home/neoney/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrurlhandler %U";
        terminal = false;
        type = "Application";
        categories = ["Game"];
        mimeType = ["x-scheme-handler/steamvr"];
      };
      valve-URI-vrmonitor = {
        name = "URI-vrmonitor";
        comment = "URI handler for vrmonitor://";
        exec = "/home/neoney/.local/share/Steam/steamapps/common/SteamVR/bin/vrmonitor.sh %U";
        terminal = false;
        type = "Application";
        categories = ["Game"];
        mimeType = ["x-scheme-handler/vrmonitor"];
      };
    };
  };
}
