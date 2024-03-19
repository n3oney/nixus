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

    home.file.".ssh/hosts".source = hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix/ssh_hosts";
  };
}
