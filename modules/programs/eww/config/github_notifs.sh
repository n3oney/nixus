#!/usr/bin/env fish

@curl@ -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $(cat /var/run/user/1000/agenix/gh_notifications_key)" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/notifications | @jaq@ -r ". | length"