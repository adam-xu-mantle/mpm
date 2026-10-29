#!/bin/bash
# SessionStart hook: if the current directory or a parent contains mpm.md, tell the agent to load mpm and run the session start check.
# Prints nothing when there is no mpm.md.
d="${CLAUDE_PROJECT_DIR:-$PWD}"
while [ "$d" != "/" ] && [ "$d" != "$(dirname "$HOME")" ]; do
  if [ -f "$d/mpm.md" ]; then
    echo "mpm working directory detected: ${d} (mpm.md exists). Before replying to the user's first message, load the mpm skill with the Skill tool and run its \"Session Start Check\": report the actual progress of each stage, then ask the user whether to continue with the next task."
    exit 0
  fi
  d="$(dirname "$d")"
done
exit 0
