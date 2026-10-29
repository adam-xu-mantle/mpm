#!/bin/bash
# Generate the mpm working directory skeleton in the target directory. Existing files are always skipped, never overwritten.
# Usage: bash scaffold.sh <target dir>
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
dir="$(cd "${1:?usage: bash scaffold.sh <target dir>}" && pwd)"

put() {  # put <relative path>, content read from stdin
  local f="$dir/$1"
  if [ -e "$f" ]; then cat >/dev/null; echo "skipped (exists): $1"; return; fi
  mkdir -p "$(dirname "$f")"; cat > "$f"; echo "created: $1"
}

stage_readme() {  # stage_readme <title> <status> <extra sections>
  printf '# %s\n\n## Status\n%s\n\n## Completion Criteria\nSee this stage'"'"'s section of ~/.claude/skills/mpm/stages.md; add project-specific criteria here.\n\n## Tasks\n\n## Deliverables\n\n%s## Upstream Changes\n\n## Reviews\n' "$1" "$2" "$3"
}

put mpm.md < "$here/templates/mpm.md"

stage_readme "01-Requirements" "In progress" "## Documents
- Industry research: [detail](research-detail.md) / [brief](research-brief.md)
- Requirement design: [detail](requirements-detail.md) / [brief](requirements-brief.md)
- External data: research-data/
- Daily research logs: research-log/

## Findings To Discuss

| Date | Finding | Requirement items possibly affected | Status |
|---|---|---|---|

" | put 01-requirements/README.md
printf '# Industry Research (Detail)\n\nReader: agents in later sessions. Be thorough: background, data, source links, options considered and trade-offs, open questions.\n' | put 01-requirements/research-detail.md
printf '# Industry Research (Brief)\n\n## Conclusion\n\n(Conclusion first. Use widely understood industry terms; no internal jargon or non-standard abbreviations. Details in research-detail.md.)\n' | put 01-requirements/research-brief.md
printf '# Requirement Design (Detail)\n\nReader: agents in later sessions. Every requirement states its acceptance criteria.\n' | put 01-requirements/requirements-detail.md
printf '# Requirement Design (Brief)\n\n## Conclusion\n\n(First paragraph: what this requirement will deliver. Use widely understood industry terms; no internal jargon or non-standard abbreviations. Details in requirements-detail.md.)\n' | put 01-requirements/requirements-brief.md

stage_readme "02-Design" "Not started" "" | put 02-design/README.md
stage_readme "03-Development" "Not started" "" | put 03-development/README.md
stage_readme "04-Self-Test" "Not started" "" | put 04-self-test/README.md

for d in 01-requirements/research-data 01-requirements/research-log \
         01-requirements/reviews 02-design/reviews 03-development/reviews 04-self-test/reviews; do
  mkdir -p "$dir/$d"; [ -e "$dir/$d/.gitkeep" ] || : > "$dir/$d/.gitkeep"
done
echo "done: $dir"
