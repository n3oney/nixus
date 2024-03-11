{hmConfig, ...}: {
  os.services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  hm = {
    programs.ssh = {
      enable = true;
      extraConfig = ''
        Include hosts
      '';
    };

    home.file.".ssh/hosts".source = hmConfig.age.secrets.ssh_hosts.path;
  };
}
