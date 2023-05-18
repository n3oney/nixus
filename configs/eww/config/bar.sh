#!/usr/bin/env fish

set lastws 2

function handle
  if string match -q -r "^workspace>>((10)|\d)\$" $argv[1]
      set ws $(string sub -s 12 $argv[1])

      set lastws $ws

      set wincount $(hyprctl clients -j | jaq -r ". | map(select (.workspace.id == $ws and .floating == false and .mapped == true)) | length")

      if test $wincount -eq 1
          echo "nogaps"
      else
          echo ""
      end
  end
  if string match -q "fullscreen>>?" $argv[1]

      set wincount $(hyprctl clients -j | jaq -r ". | map(select (.workspace.id == $lastws and .floating == false and .mapped == true)) | length")
      set fswincount $(hyprctl clients -j | jaq -r ". | map(select (.workspace.id == $lastws and .fullscreen == true and .mapped == true)) | length")

      if test $wincount -eq 1
        or test $fswincount -ne 0

        echo "nogaps"
      else
        echo ""
      end
  end
  if test -n $lastws

    if string match -q "changefloatingmode>>*" $argv[1]
      or string match -q "movewindow>>*" $argv[1]
      or string match -q "openwindow>>*" $argv[1]
      or string match -q "closewindow>>*" $argv[1]
  
        set wincount $(hyprctl clients -j | jaq -r ". | map(select (.workspace.id == $lastws and .floating == false and .mapped == true)) | length")

        if test $wincount -eq 1
            echo "nogaps"
        else
            echo ""
        end
    end
  end
end

socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read line; handle $line; end
