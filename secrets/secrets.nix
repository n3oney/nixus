let
  miko_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHRyeXj99ydcyzJtpZoZ5nMz0oOU97tIZMsygWecUtOk";
  vic_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnnJimJIwFnqkC5GTWM3lq6QTfjA8rJldKu4ue3ckih";
  maya_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJByA+ZlxOI6VEG+QXqYQu80PtfdNMXRwbERqiC4vUR";
  max_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgayxuDLXH6QYqoFJeEqqKo5/6fqfuS4fOYN9TaL6Rj";

  miko_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO6PmYOYdJT8IDzgbWp8oHo3h4KCfg9AGjty8fRn/QK";
  vic_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILlkZf59+zbc+mtODZdTZbPpKLFVYxLXbrpzSqWE6XDY";
  maya_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuP7PM81YCMmifSPC/tBHEJ4jKI9HAGxAUDqP5PQIiB";
  max_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4j2OzWCrqgW/5BieZyloZFxS1dfiC/KO41P5b9iYzM";

  miko = [miko_user miko_host];
  vic = [vic_user vic_host];
  maya = [maya_user maya_host];
  max = [max_user max_host];
in {
  "ha_assist_config.age".publicKeys = miko ++ vic;
  "gh_notifications_key.age".publicKeys = miko ++ vic;
  "wakatime.age".publicKeys = miko ++ vic ++ maya ++ max;
  "cloudflared.age".publicKeys = miko ++ max;

  "wg.age".publicKeys = miko ++ vic;

  "ssh_hosts.age".publicKeys = miko ++ vic ++ maya ++ max;

  "ngrok.age".publicKeys = miko ++ vic ++ maya ++ max;
  "uonetplan.age".publicKeys = miko ++ vic ++ maya;

  "shibabot.age".publicKeys = miko ++ vic ++ maya;
}
