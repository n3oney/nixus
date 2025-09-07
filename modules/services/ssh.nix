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
      matchBlocks."*" = {
        forwardAgent = false;
        addKeysToAgent = "yes";
        compression = false;
        serverAliveInterval = 0;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
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
