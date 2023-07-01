#!@fish@

set speaker_sink @speakerSink@

function run
  switch "$argv[1]"
    case "volume"
      @pamixer@ --get-volume;
      @pactl@ subscribe \
        | stdbuf -o0 grep --line-buffered "Event 'change' on sink " \
        | while read -L evt 
            @pamixer@ --get-volume | cut -d " " -f1
          end

    case "volume-speakers"
      if test -z "$speaker_sink"
        echo -1
        sleep infinity
      else
        set speakers $(@pamixer@ --list-sinks | grep -e "$speaker_sink" | awk '{print $1}')

        while test -z $speakers
          sleep 1
          set speakers $(@pamixer@ --list-sinks | grep -e "$speaker_sink" | awk '{print $1}')
        end

        @pamixer@ --get-volume --sink $speakers

        @pactl@ subscribe \
            | stdbuf -o0 grep --line-buffered "Event 'change' on sink #$speakers" \
            | while read -L evt
                @pamixer@ --get-volume --sink $speakers | cut -d " " -f1
              end
      end
    
    case "muted"
      if test $(@pamixer@ --get-mute) = "true"
          echo "volume muted"
      else
          echo "volume"
      end

      @pactl@ subscribe \
        | stdbuf -o0 grep --line-buffered "Event 'change' on sink " \
        | while read -L evt
            if test $(@pamixer@ --get-mute) = "true"
                echo "volume muted"
            else
                echo "volume"
            end
          end
    case "speaker-muted"
      if test -z "$speaker_sink"
        echo "volume missing"
        sleep infinity
      else
        set speakers $(@pamixer@ --list-sinks | grep -e "$speaker_sink" | awk '{print $1}')

        while test -z $speakers
          sleep 1
          set speakers $(@pamixer@ --list-sinks | grep -e "$speaker_sink" | awk '{print $1}')
        end

        if test $(@pamixer@ --get-mute --sink $speakers) = "true"
            echo "volume muted"
        else
            echo "volume"
        end
      
        @pactl@ subscribe \
          | stdbuf -o0 grep --line-buffered "Event 'change' on sink #$speakers" \
          | while read -r evt
              if test $(@pamixer@ --get-mute --sink $speakers) = "true"
                  echo "volume muted"
              else
                  echo "volume"
              end
            end
      end
  end
end


while true 
    run $argv[1]
    echo "Crashed. Respawning..." >&2
    sleep 1
end
