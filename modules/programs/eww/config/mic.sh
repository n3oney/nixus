#!/usr/bin/env bash

MIC_NAME="Blue Snowball Mono"

run() {
  source_index=$(@pactl@ -f json list sources | @jaq@ -r ".[] | select( .description == \"$MIC_NAME\" ).index")
  @pactl@ --format json list source-outputs | @jaq@ -r ". | map(select (.source == $source_index and .properties[\"application.name\"] != \"PulseAudio Volume Control\")) | length"

  @pactl@ subscribe \
      | grep --line-buffered -E "'((new)|(remove))' on source-output" \
      | while read -r evt; do 
        source_index=$(@pactl@ -f json list sources | @jaq@ -r ".[] | select( .description == \"$MIC_NAME\" ).index")
 
        @pactl@ --format json list source-outputs | @jaq@ -r ". | map(select (.source == $source_index and .properties[\"application.name\"] != \"PulseAudio Volume Control\")) | length"
      done
}

while true; do 
    run
    echo "Script exited. Restarting..." >&2
    sleep 1
done
