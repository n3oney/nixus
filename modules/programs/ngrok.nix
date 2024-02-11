{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  options.programs.ngrok.enable = lib.mkEnableOption "ngrok";

  config.hm = lib.mkIf config.programs.ngrok.enable {
    home.packages = [pkgs.ngrok];

    systemd.user.services.ngrokConfig = {
      Unit = {
        Requires = "agenix.service";
        After = "agenix.service";
      };
      Install.WantedBy = ["default.target"];

      Service = {
        Type = "simple";
        ExecStart = let
          cfg = ''
            version: "2"
            authtoken: @TOKEN@
          '';
        in
          pkgs.writeShellScript "ngrok-setup.sh" ''
            mkdir -p "${hmConfig.xdg.configHome}/ngrok"

            echo -e ${builtins.toJSON (builtins.replaceStrings ["@TOKEN@"] ["$(cat ${hmConfig.age.secrets.ngrok.path})"] cfg)} > ${hmConfig.xdg.configHome}/ngrok/ngrok.yml
          '';
      };
    };
  };
}
