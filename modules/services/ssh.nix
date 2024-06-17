{hmConfig, ...}: {
  os.services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  os.environment.extraInit = ''
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
      export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent
    fi
  '';

  hm = {
    programs.ssh = {
      enable = true;
      addKeysToAgent = "yes";
      extraConfig = ''
        Include hosts
      '';
    };

    services.ssh-agent = {
      enable = true;
    };

    home.file.".ssh/hosts".source = hmConfig.lib.file.mkOutOfStoreSymlink "/run/user/1000/agenix/ssh_hosts";
  };
}
