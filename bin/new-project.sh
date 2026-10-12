#!/usr/bin/env bash
# Stamp the Claude Code structure into a project, plus any library items you pick.
# Usage: bin/new-project.sh <project-dir> [library-item ...]
#   e.g. bin/new-project.sh ~/code/my-app skills/wrangler agents/code-reviewer.md plugins/frontend-design@claude-plugins-official
# Never overwrites files that already exist in the project.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
target="${1:?usage: new-project.sh <project-dir> [library-item ...]}"; shift
mkdir -p "$target"

cp -r --update=none "$here/template/." "$target/"
echo "Structure copied into $target (existing files left untouched)"

for item in "$@"; do
  if [[ "$item" == plugins/* ]]; then   # plugins are installed by Claude, not copied
    (cd "$target" && claude plugin install "${item#plugins/}" --scope project -y >/dev/null) \
      && echo "  + $item (installed, listed in .claude/settings.json)" || echo "  ! plugin install failed: $item"
    continue
  fi
  src="$here/library/$item"
  [[ -e "$src" ]] || { echo "  ! not in library: $item"; continue; }
  dest="$target/.claude/$item"
  mkdir -p "$(dirname "$dest")"
  cp -r --update=none "$src" "$dest"
  echo "  + $item"
  if [[ -f "$dest/claude-settings.json" ]]; then   # a hook folder: register it in settings.json
    python3 -I - "$dest/claude-settings.json" "$target/.claude/settings.json" <<'PY'
import json, sys
new, path = json.load(open(sys.argv[1])), sys.argv[2]
s = json.load(open(path))
for ev, entries in new["hooks"].items():
    have = s.setdefault("hooks", {}).setdefault(ev, [])
    for e in entries:
        if e not in have: have.append(e)
with open(path, "w") as f: json.dump(s, f, indent=2); f.write("\n")
PY
    echo "    registered in .claude/settings.json"
  fi
done

cat <<MSG

Next:
  1. cd $target && claude
  2. Run /init so Claude fills CLAUDE.md / AGENTS.md from the real code
  3. Edit .claude/skills/deploy/deploy-config.md and .mcp.json for this project
MSG
