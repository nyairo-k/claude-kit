#!/usr/bin/env bash
# Installs the Claude Code kit (template/, library/, bin/) with one command. Needs only curl and tar.
#
#   curl -fsSL https://raw.githubusercontent.com/nyairo-k/claude-kit/main/install.sh | bash
#
# Options (environment variables):
#   KIT_DIR=~/claude-kit   where to install
#   KIT_REPO=nyairo-k/claude-kit    which GitHub repo to download
#   KIT_REF=main           branch or tag
set -euo pipefail
KIT_REPO="${KIT_REPO:-nyairo-k/claude-kit}"
KIT_REF="${KIT_REF:-main}"
KIT_DIR="${KIT_DIR:-$HOME/claude-kit}"
KIT_URL="${KIT_URL:-https://github.com/$KIT_REPO/archive/refs/heads/$KIT_REF.tar.gz}"

say() { printf '\033[1m%s\033[0m\n' "$*"; }
need() { command -v "$1" >/dev/null 2>&1 || { echo "error: '$1' is required but not installed" >&2; exit 1; }; }
need curl; need tar; need python3

if [[ -d "$KIT_DIR" && -z "${KIT_UPDATE:-}" ]]; then
  say "Already installed at $KIT_DIR"
  echo "  to update bin/ and template/:  kit update"
  echo "  to install elsewhere:          KIT_DIR=~/other-folder bash install.sh"
  exit 0
fi

tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
say "Downloading kit from $KIT_REPO ($KIT_REF)..."
curl -fsSL "$KIT_URL" -o "$tmp/kit.tar.gz" || { echo "error: download failed: $KIT_URL" >&2; exit 1; }
tar -xzf "$tmp/kit.tar.gz" -C "$tmp"
src="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -1)"
[[ -d "$src/bin" && -d "$src/template" ]] || { echo "error: archive doesn't look like the kit" >&2; exit 1; }

if [[ -n "${KIT_UPDATE:-}" ]]; then
  say "Updating bin/, template/, install.sh and README in $KIT_DIR (library/ untouched)..."
  rm -rf "$KIT_DIR/bin" "$KIT_DIR/template"
  cp -r "$src/bin" "$src/template" "$src/install.sh" "$src/README.md" "$KIT_DIR/"
else
  say "Installing to $KIT_DIR..."
  mkdir -p "$KIT_DIR"
  cp -r "$src"/. "$KIT_DIR"/
fi
chmod +x "$KIT_DIR"/bin/* "$KIT_DIR"/template/.claude/hooks/* "$KIT_DIR"/library/hooks/* 2>/dev/null || true

# put `kit` on the PATH (bash and zsh)
line="export PATH=\"$KIT_DIR/bin:\$PATH\"   # claude-kit"
added=
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f "$rc" ]] || continue
  grep -qF '# claude-kit' "$rc" || { printf '\n%s\n' "$line" >> "$rc"; added=1; }
done
[[ -f "$HOME/.bashrc" || -f "$HOME/.zshrc" ]] || { printf '%s\n' "$line" >> "$HOME/.bashrc"; added=1; }

say "Done."
cat <<MSG

  Kit folder:  $KIT_DIR
  Command:     kit        (open a new terminal first${added:+, or run: source ~/.bashrc})

  kit fetch find <topic>                 search for skills
  kit list                               what's in the library
  kit new ~/my-app skills/<name> ...     set up a project
  kit link skills/<name> ...             use an item in every project
  kit update                             get the latest bin/ and template/

MSG
