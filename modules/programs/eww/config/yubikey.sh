#!/usr/bin/env fish

set u2f 0
set gpg 0

function handle
  switch $argv[1]
    case U2F_1
      set u2f 1
    case U2F_0
      set u2f 0
    case GPG_1
      set gpg 1
    case GPG_0
      set gpg 0
  end

  echo "{\"u2f\":$u2f,\"gpg\":$gpg}"
end

echo "{\"u2f\":$u2f,\"gpg\":$gpg}"
@socat@ -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/yubikey-touch-detector.socket" | while read -n5 line; handle $line; end
