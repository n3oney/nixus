let
  miko_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHRyeXj99ydcyzJtpZoZ5nMz0oOU97tIZMsygWecUtOk";
  yen_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJJByA+ZlxOI6VEG+QXqYQu80PtfdNMXRwbERqiC4vUR";
  endurance_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINgayxuDLXH6QYqoFJeEqqKo5/6fqfuS4fOYN9TaL6Rj";
  prism_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK/6B/hbuNdUQsrIsUUJ6wjT+3umZj8wdcmX9KQ7oiSy";

  miko_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO6PmYOYdJT8IDzgbWp8oHo3h4KCfg9AGjty8fRn/QK";
  yen_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuP7PM81YCMmifSPC/tBHEJ4jKI9HAGxAUDqP5PQIiB";
  endurance_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO4j2OzWCrqgW/5BieZyloZFxS1dfiC/KO41P5b9iYzM";
  prism_host = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMAUC0JjvU+pLxLmvluh5rfQwQGaQM+y1qJrc/hVOiAr";

  miko = [miko_user miko_host];
  yen = [yen_user yen_host];
  endurance = [endurance_user endurance_host];
  prism = [prism_user prism_host];
in {
  "ha_assist_config.age".publicKeys = miko ++ prism;
  "gh_notifications_key.age".publicKeys = miko ++ prism;
  "gh_token.age".publicKeys = miko ++ prism;
  "cloudflared.age".publicKeys = miko ++ endurance ++ prism;

  "ssh_hosts.age".publicKeys = miko ++ yen ++ endurance ++ prism;

  "ngrok.age".publicKeys = miko ++ yen ++ endurance ++ prism;

  "z2m.age".publicKeys = miko ++ endurance ++ prism;

  "mcp.age".publicKeys = miko ++ prism;

  "norish.age".publicKeys = miko ++ prism ++ endurance;

  "binary-cache-miko.age".publicKeys = miko;
}
