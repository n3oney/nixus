#!/usr/bin/env bash


run() {
    case "$1" in
  "volume")
    @pamixer@ --get-volume; 
    @pactl@ subscribe \
      | grep --line-buffered "Event 'change' on sink " \
      | while read -r evt; 
      do @pamixer@ --get-volume | cut -d " " -f1;
    done

    ;;
  "volume-speakers")
    speakers=$(@pamixer@ --list-sinks | grep -e 'raop_sink.raspberrypi.local.192.168.1.4.5000' | awk '{print $1}')

    while [ -z $speakers ]; do
      speakers=$(@pamixer@ --list-sinks | grep -e 'raop_sink.raspberrypi.local.192.168.1.4.5000' | awk '{print $1}')
    done

    @pamixer@ --get-volume --sink $speakers

    @pactl@ subscribe \
        | grep --line-buffered "Event 'change' on sink #$speakers" \
        | while read -r evt;
        do @pamixer@ --get-volume --sink $speakers | cut -d " " -f1;
    done
    ;;
  "muted")
      if [[ $(@pamixer@ --get-mute) == "true" ]]; then
          echo "volume muted"
      else
          echo "volume"
      fi
    @pactl@ subscribe \
      | grep --line-buffered "Event 'change' on sink " \
      | while read -r evt; 
      do
      if [[ $(@pamixer@ --get-mute) == "true" ]]; then
          echo "volume muted"
      else
          echo "volume"
      fi

    done
    ;;
  "speaker-muted")
    speakers=$(@pamixer@ --list-sinks | grep -e 'raop_sink.raspberrypi.local.192.168.1.4.5000' | awk '{print $1}')

    while [ -z $speakers ]; do
      speakers=$(@pamixer@ --list-sinks | grep -e 'raop_sink.raspberrypi.local.192.168.1.4.5000' | awk '{print $1}')
    done

    if [[ $(@pamixer@ --get-mute --sink $speakers) == "true" ]]; then
        echo "volume muted"
    else
        echo "volume"
    fi
        
    @pactl@ subscribe \
      | grep --line-buffered "Event 'change' on sink #$speakers" \
      | while read -r evt; 
      do
      if [[ $(@pamixer@ --get-mute --sink $speakers) == "true" ]]; then
          echo "volume muted"
      else
          echo "volume"
      fi

    done
    ;;
esac
}

while true; do 
    run $1
    echo "Crashed. Respawning..." >&2
    sleep 1
done
