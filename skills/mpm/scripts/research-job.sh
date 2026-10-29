#!/bin/bash
# Manage the launchd job that runs mpm's daily industry research.
# Usage:
#   bash research-job.sh install   <working dir> [hour, default 9] [minute, default 7]
#   bash research-job.sh uninstall <working dir>
#   bash research-job.sh status    <working dir>
#   bash research-job.sh run       <working dir>     # run once now (this is also what launchd calls)
set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cmd="${1:-}"; dir="${2:-}"
[ -n "$cmd" ] && [ -n "$dir" ] || { sed -n '2,7p' "$0"; exit 2; }
dir="$(cd "$dir" && pwd)"
[ -f "$dir/mpm.md" ] || { echo "error: no mpm.md in $dir" >&2; exit 1; }

slug="$(basename "$dir" | tr -c 'A-Za-z0-9_-\n' '-')-$(printf '%s' "$dir" | shasum | cut -c1-8)"
label="com.mpm.research.$slug"
plist="$HOME/Library/LaunchAgents/$label.plist"
log_dir="$dir/01-requirements/research-log"

case "$cmd" in
  run)
    mkdir -p "$log_dir" "$dir/01-requirements/research-data"
    claude_bin="$(command -v claude || echo /opt/homebrew/bin/claude)"
    cd "$dir"
    {
      echo "=== $(date '+%F %T') start ==="
      "$claude_bin" -p "$(cat "$SKILL_DIR/daily-research.md")" \
        --allowedTools "Read" "Glob" "Grep" "WebSearch" "WebFetch" \
          "Write(./01-requirements/research-log/**)" "Edit(./01-requirements/research-log/**)" \
          "Write(./01-requirements/research-data/**)" "Edit(./01-requirements/research-data/**)" \
          "Edit(./01-requirements/README.md)" \
        --permission-mode dontAsk && rc=0 || rc=$?
      echo "=== $(date '+%F %T') end, exit code $rc ==="
    } >> "$log_dir/.runner.log" 2>&1
    ;;
  install)
    hour="${3:-9}"; minute="${4:-7}"
    mkdir -p "$HOME/Library/LaunchAgents" "$log_dir"
    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key><array>
    <string>/bin/bash</string><string>$SKILL_DIR/scripts/research-job.sh</string>
    <string>run</string><string>$dir</string>
  </array>
  <key>EnvironmentVariables</key><dict>
    <key>PATH</key><string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
  </dict>
  <key>StartCalendarInterval</key><dict>
    <key>Hour</key><integer>$hour</integer><key>Minute</key><integer>$minute</integer>
  </dict>
  <key>StandardErrorPath</key><string>$log_dir/.launchd.err</string>
</dict></plist>
EOF
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    launchctl bootstrap "gui/$(id -u)" "$plist"
    echo "installed: $label, runs daily at $(printf '%02d:%02d' "$hour" "$minute"); logs in $log_dir/"
    ;;
  uninstall)
    launchctl bootout "gui/$(id -u)/$label" 2>/dev/null || true
    [ -f "$plist" ] && mv "$plist" "$plist.disabled"
    echo "uninstalled: $label"
    ;;
  status)
    if launchctl print "gui/$(id -u)/$label" >/dev/null 2>&1; then echo "installed: $label"; else echo "not installed: $label"; fi
    latest="$(ls "$log_dir" 2>/dev/null | grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}\.md$' | tail -1 || true)"
    echo "latest research log: ${latest:-none}"
    ;;
  *) sed -n '2,7p' "$0"; exit 2 ;;
esac
