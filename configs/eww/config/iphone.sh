#!/usr/bin/env bash

get_batt() {
  value=$(ideviceinfo -n -q com.apple.mobile.battery -k BatteryCurrentCapacity 2>/dev/null)
  if [[ "$value" =~ ^.*ERROR.* ]] || [[ -z "$value" ]]; then
    return 1
  fi
  echo $value
}



old_percentage=$(get_batt || echo "")

while true
do
  new_percentage=$(get_batt)
  if [[ -z "$new_percentage" ]]; then
    echo "{\"percentage\": \"$old_percentage\", \"connected\": false}"
  else
    echo "{\"percentage\": \"$new_percentage\", \"connected\": true}"
    old_percentage="$new_percentage"
  fi
  sleep 5
done

