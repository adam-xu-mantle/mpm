#!/bin/bash
# Install mpm: copy the skills under skills/ to ~/.claude/skills/ and add a SessionStart hook to ~/.claude/settings.json.
# Usage: bash install.sh            install by copying
#        bash install.sh --link     install via symlinks (edits to this repo take effect immediately; good for skill development)
set -euo pipefail
repo="$(cd "$(dirname "$0")" && pwd)"
skills_dir="${CLAUDE_HOME:-$HOME/.claude}/skills"
settings="${CLAUDE_HOME:-$HOME/.claude}/settings.json"
hook_cmd='bash ~/.claude/skills/mpm/scripts/session-start.sh 2>/dev/null || true'
mode="${1:-}"

command -v jq >/dev/null || { echo "error: jq is required (brew install jq)" >&2; exit 1; }
mkdir -p "$skills_dir"

# Backups go outside skills/, otherwise Claude Code would load them as duplicate skills.
backup_dir="${CLAUDE_HOME:-$HOME/.claude}/skills-backup/$(date +%Y%m%d%H%M%S)"
for name in mpm mpm-create; do
  target="$skills_dir/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    mkdir -p "$backup_dir"
    backup="$backup_dir/$name"
    mv "$target" "$backup"
    echo "backed up existing $name -> $backup"
  fi
  if [ "$mode" = "--link" ]; then
    ln -s "$repo/skills/$name" "$target"; echo "linked: $target -> $repo/skills/$name"
  else
    cp -R "$repo/skills/$name" "$target"; echo "copied: $target"
  fi
done

[ -f "$settings" ] || echo '{}' > "$settings"
if jq -e --arg c "$hook_cmd" '[.hooks.SessionStart[]?.hooks[]?.command] | index($c)' "$settings" >/dev/null; then
  echo "SessionStart hook already present, skipping"
else
  cp "$settings" "$settings.bak.$(date +%Y%m%d%H%M%S)"
  tmp="$(mktemp)"
  jq --arg c "$hook_cmd" '.hooks.SessionStart = ((.hooks.SessionStart // []) + [{"matcher": "startup|resume|clear", "hooks": [{"type": "command", "command": $c}]}])' "$settings" > "$tmp"
  mv "$tmp" "$settings"
  echo "added SessionStart hook to $settings (original backed up)"
fi
echo "done. Takes effect in new Claude Code sessions."
