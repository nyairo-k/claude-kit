#!/usr/bin/env bash
# Make library items available in EVERY project (user scope) by linking them into ~/.claude/.
# Usage:  bin/link-global.sh skills/gsap-core rules/html-css-style-color-guide.md plugins/frontend-design@claude-plugins-official
#         bin/link-global.sh --remove skills/gsap-core      # undo (library copy stays)
#         bin/link-global.sh --list                          # what is linked now
# Edits in the library show up everywhere instantly, since these are links.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
mode=add; [[ "${1:-}" == "--remove" ]] && { mode=remove; shift; }
if [[ "${1:-}" == "--list" ]]; then
  find "$HOME/.claude"/{skills,agents,rules,hooks} -maxdepth 1 -type l -lname "$here/*" 2>/dev/null | sed "s#$HOME/.claude/#  #" || true
  claude plugin list 2>/dev/null | grep -E '^\s*[>-] ' | sed 's/^/  plugin /' || true
  exit 0
fi
for item in "$@"; do
  if [[ "$item" == plugins/* ]]; then
    p="${item#plugins/}"
    if [[ $mode == add ]]; then claude plugin install "$p" --scope user -y >/dev/null && echo "  + plugin $p (user scope)"
    else claude plugin uninstall "$p" --scope user >/dev/null && echo "  - plugin $p"; fi
    continue
  fi
  src="$here/library/$item"; dest="$HOME/.claude/$item"
  if [[ $mode == remove ]]; then
    [[ -L "$dest" ]] && rm "$dest" && echo "  - $item" || echo "  ! not linked: $item"; continue
  fi
  [[ -e "$src" ]] || { echo "  ! not in library: $item"; continue; }
  if [[ -e "$dest" && ! -L "$dest" ]]; then echo "  ! ~/.claude/$item exists and is not a link, skipping"; continue; fi
  mkdir -p "$(dirname "$dest")"; ln -sfn "$src" "$dest"; echo "  + $item -> ~/.claude/$item"
done
