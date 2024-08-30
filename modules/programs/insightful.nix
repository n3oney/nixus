{
  pkgs,
  lib,
  config,
  ...
}: {
  options.programs.insightful.enable = lib.mkEnableOption "Insightful";

  config.hm = lib.mkIf config.programs.insightful.enable (let
    insightful = (
      pkgs.appimageTools.wrapType2 {
        pname = "insightful";
        version = "0.0.1";

        src = pkgs.fetchurl {
          url = "https://insightful-updates.io/linux/agent/latest/Workpuls.AppImage";
          hash = "sha256-Jt4ylRpBavrJb/iJtW0lzoI/5NuMYulaakdFMNTofSk=";
        };
      }
    );
  in {
    xdg.desktopEntries.insightful = {
      exec = "${insightful}/bin/insightful";
      name = "Insightful Track";
    };

    home.packages = [
      insightful
    ];
  });
}
