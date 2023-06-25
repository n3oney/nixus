#!/usr/bin/env fish

set share_count 0

echo $share_count

function handle
  if string match -q "screencast>>1,?" $argv[1]
      set share_count $(math $share_count + 1)
      echo $share_count
  else if string match -q "screencast>>0,?" $argv[1]
      set share_count $(math $share_count - 1)
      echo $share_count
  end
end

@socat@ -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read line; handle $line; end
