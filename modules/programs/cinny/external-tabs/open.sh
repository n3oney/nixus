#!/usr/bin/env bash


# Function to read a specific number of bytes from stdin
read_bytes() {
    local count=$1
    dd bs=1 count="$count" 2>/dev/null
}

# Function to convert 4-byte binary data to an integer
binary_to_int() {
    local binary_data=$1
    echo $(( $(printf '%d' "'${binary_data:3:1}") + \
             $(printf '%d' "'${binary_data:2:1}") * 256 + \
             $(printf '%d' "'${binary_data:1:1}") * 65536 + \
             $(printf '%d' "'${binary_data:0:1}") * 16777216 ))
}

while true; do

# Read the first 4 bytes to get the length
raw_length=$(read_bytes 4)

# Exit if raw_length is empty
if [ -z "$raw_length" ]; then
    exit 0
fi

# Convert raw_length to integer
message_length=$(binary_to_int "$raw_length")

# Read the message of length message_length
message=$(read_bytes "$message_length")

# Output the message (assuming it is a valid JSON string)
xdg-open $(echo "$message" | jaq -r .url)

done
