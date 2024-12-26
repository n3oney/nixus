let
  miko_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHRyeXj99ydcyzJtpZoZ5nMz0oOU97tIZMsygWecUtOk";
  ciri_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnnJimJIwFnqkC5GTWM3lq6QTfjA8rJldKu4ue3ckih";
  yen_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJByA+ZlxOI6VEG+QXqYQu80PtfdNMXRwbERqiC4vUR";
  max_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgayxuDLXH6QYqoFJeEqqKo5/6fqfuS4fOYN9TaL6Rj";

  miko_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO6PmYOYdJT8IDzgbWp8oHo3h4KCfg9AGjty8fRn/QK";
  ciri_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILlkZf59+zbc+mtODZdTZbPpKLFVYxLXbrpzSqWE6XDY";
  yen_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuP7PM81YCMmifSPC/tBHEJ4jKI9HAGxAUDqP5PQIiB";
  max_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4j2OzWCrqgW/5BieZyloZFxS1dfiC/KO41P5b9iYzM";

  miko = [miko_user miko_host];
  ciri = [ciri_user ciri_host];
  yen = [yen_user yen_host];
  max = [max_user max_host];
in {
  "ha_assist_config.age".publicKeys = miko ++ ciri;
  "gh_notifications_key.age".publicKeys = miko ++ ciri;
  "wakatime.age".publicKeys = miko ++ ciri ++ yen ++ max;
  "cloudflared.age".publicKeys = miko ++ max;

  "ssh_hosts.age".publicKeys = miko ++ ciri ++ yen ++ max;

  "ngrok.age".publicKeys = miko ++ ciri ++ yen ++ max;

  "shibabot.age".publicKeys = miko ++ ciri ++ yen;
}
