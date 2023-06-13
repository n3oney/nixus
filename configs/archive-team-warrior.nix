{
  system = _: {
    virtualisation.docker.enable = true;

    virtualisation.oci-containers.backend = "docker";
    virtualisation.oci-containers.containers = {
      archive-team-warrior = {
        image = "atdr.meo.ws/archiveteam/reddit-grab";
        autoStart = true;
        cmd = ["--concurrent=4" "neoney"];
        extraOptions = ["--network=host"];
      };
    };
  };
}
