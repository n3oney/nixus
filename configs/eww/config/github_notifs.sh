#!/usr/bin/env fish

gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" /notifications | jaq -r ". | length"