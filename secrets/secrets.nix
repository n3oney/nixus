let
  nixus_pc_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHRyeXj99ydcyzJtpZoZ5nMz0oOU97tIZMsygWecUtOk";
  zia_user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILEbP6w13AG23+e8GFD8fXH6c/VgIYKgoJ3D1xEZgNwF";

  nixus_pc = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICO6PmYOYdJT8IDzgbWp8oHo3h4KCfg9AGjty8fRn/QK";
  zia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAAkd9xLNVJa3F4EoQiZICAgDKbjSYwLdzsupsDhUcJm";

  users = [nixus_pc_user zia_user];
  systems = [nixus_pc zia];
in {
  "ha_assist_config.age".publicKeys = users ++ systems;
  "gh_notifications_key.age".publicKeys = users ++ systems;
}
