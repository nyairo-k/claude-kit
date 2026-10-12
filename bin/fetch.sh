#!/usr/bin/env bash
# Find things online and save the ones you choose into library/ (your catalogue).
# Downloads only what you name. Every item is recorded in library/CATALOGUE.md.
#
# SEARCH
#   bin/fetch.sh find <query>                search ~all public skills (skills.sh index)
#   bin/fetch.sh browse rules|agents|hooks [word]   awesome-copilot
#   bin/fetch.sh browse plugins [word]       plugins in your Claude marketplaces
#   bin/fetch.sh browse claude [word]        awesome-claude-code: 249 projects (word "categories" lists them)
#   bin/fetch.sh inspect <github-url>        what's inside a project + the command to fetch it
# SAVE
#   bin/fetch.sh skill <owner/repo@skill>    e.g. cloudflare/skills@wrangler
#   bin/fetch.sh rule  <name|github-url>     name = an awesome-copilot instruction, e.g. python
#   bin/fetch.sh agent <name|github-url>     name = an awesome-copilot agent
#   bin/fetch.sh hook  <name|github-url>     name = an awesome-copilot hook (converted for Claude)
#   bin/fetch.sh marketplace <owner/repo>    add a plugin collection, then browse plugins
#   bin/fetch.sh plugin <name@marketplace>   remember a plugin in library/plugins.txt
#   bin/fetch.sh list                        show what's in your library
#
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
lib="$here/library"
catalogue="$lib/CATALOGUE.md"
AC="https://raw.githubusercontent.com/github/awesome-copilot/main"

record() {  # type name source
  [[ -f "$catalogue" ]] || printf '| Type | Name | Source | Added |\n|---|---|---|---|\n' > "$catalogue"
  printf '| %s | %s | %s | %s |\n' "$1" "$2" "$3" "$(date +%F)" >> "$catalogue"
  echo "  + $1: library/$4   (review it before using: it runs with Claude's permissions)"
}

raw_url() {  # github.com/.../blob/... -> raw.githubusercontent.com/...
  sed -E 's#https://github.com/([^/]+)/([^/]+)/blob/#https://raw.githubusercontent.com/\1/\2/#' <<<"$1"
}

download() {  # url dest
  [[ -e "$2" ]] && { echo "  ! already in library: ${2#$lib/}"; exit 1; }
  curl -fsSL "$1" -o "$2" || { echo "  ! download failed: $1"; rm -f "$2"; exit 1; }
}

cmd="${1:-help}"; shift || true
case "$cmd" in
  find)
    npx -y skills find "$@" ;;

  browse)
    case "${1:-}" in rules) dir=instructions; ext=.instructions.md;; agents) dir=agents; ext=.agent.md;;
      hooks)
        curl -fsSL https://api.github.com/repos/github/awesome-copilot/contents/hooks \
          | python3 -Ic "import json,sys; [print(x['name']) for x in json.load(sys.stdin) if x['type']=='dir']" \
          | grep -i -- "${2:-}" | while read -r h; do
              printf '%-28s %s\n' "$h" "$(curl -fsSL "$AC/hooks/$h/README.md" 2>/dev/null | grep -m1 -vE '^(#|---|[a-z]+:|\s*$)' | cut -c1-90)"
            done; exit 0;;
      plugins)
        for m in "$HOME"/.claude/plugins/marketplaces/*/.claude-plugin/marketplace.json; do
          python3 -Ic "import json,sys; d=json.load(open(sys.argv[1]))
for p in d['plugins']: print(f\"{p['name']}@{d['name']}  -  {p.get('description','')[:90]}\")" "$m"
        done | grep -i -- "${2:-}"; exit 0;;
      claude)
        curl -fsSL https://raw.githubusercontent.com/hesreallyhim/awesome-claude-code/main/THE_RESOURCES_TABLE_NEW.csv \
          | python3 -I -c '
import csv, sys, collections
word = sys.argv[1].lower()
rows = [r for r in csv.DictReader(sys.stdin) if r["Active"] == "TRUE" and r["Stale"] != "TRUE"]
if word == "categories":
    for c, n in collections.Counter(r["Category"] for r in rows).most_common(): print(f"{n:4}  {c}")
    sys.exit()
for r in rows:
    name, cat, link, desc = r["Display Name"], r["Category"], r["Link"], r["Description"]
    if word in " ".join((name, cat, r["Sub-Category"], desc)).lower():
        print(f"{name}  [{cat}]\n  {link}\n  {desc[:110]}\n")
' "${2:-}"; exit 0;;
      *) echo "usage: fetch.sh browse rules|agents|hooks|plugins|claude [word]"; exit 1;; esac
    curl -fsSL "https://api.github.com/repos/github/awesome-copilot/contents/$dir" \
      | python3 -Ic "import json,sys; [print(x['name'].removesuffix('$ext')) for x in json.load(sys.stdin)]" \
      | grep -i -- "${2:-}" | column ;;

  skill)
    spec="${1:?usage: fetch.sh skill <owner/repo@skill>}"
    repo="${spec%@*}"; name="${spec#*@}"
    [[ "$repo" != "$spec" ]] || { echo "  ! use the form owner/repo@skill (copy it from 'fetch.sh find')"; exit 1; }
    [[ -e "$lib/skills/$name" ]] && { echo "  ! already in library: skills/$name"; exit 1; }
    tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
    (cd "$tmp" && npx -y skills add "$repo" --skill "$name" -a claude-code --copy -y >/dev/null 2>&1) || true
    [[ -d "$tmp/.claude/skills/$name" ]] || { echo "  ! skill '$name' not found in $repo"; exit 1; }
    mv "$tmp/.claude/skills/$name" "$lib/skills/$name"
    record skill "$name" "$spec" "skills/$name/" ;;

  rule)
    src="${1:?usage: fetch.sh rule <name|github-url>}"
    if [[ "$src" == http* ]]; then url=$(raw_url "$src"); name=$(basename "$url" | sed -E 's/(\.instructions)?\.md$//')
    else url="$AC/instructions/$src.instructions.md"; name="$src"; fi
    out="$lib/rules/$name.md"
    download "$url" "$out"
    # Copilot's `applyTo: "a,b"` -> Claude's `paths:` list
    python3 -I - "$out" <<'PY'
import re, sys
p = sys.argv[1]; t = open(p, encoding="utf-8").read()
def fix(m):
    g = [x.strip().strip("'\"") for x in m.group(1).strip().strip("'\"").split(",") if x.strip()]
    return "" if g in (["**"], ["**/*"]) else "paths:\n" + "".join(f'  - "{x}"\n' for x in g)
t = re.sub(r"^applyTo:\s*(.+)\n", fix, t, count=1, flags=re.M)
t = re.sub(r"^---\n---\n", "", t)
open(p, "w", encoding="utf-8").write(t)
PY
    record rule "$name" "$url" "rules/$name.md" ;;

  agent)
    src="${1:?usage: fetch.sh agent <name|github-url>}"
    if [[ "$src" == http* ]]; then url=$(raw_url "$src"); name=$(basename "$url" | sed -E 's/(\.agent)?\.md$//')
    else url="$AC/agents/$src.agent.md"; name="$src"; fi
    download "$url" "$lib/agents/$name.md"
    # Copilot agent -> Claude agent: name = file name, Claude model, Claude tool names
    python3 -I - "$lib/agents/$name.md" "$name" <<'PY2'
import re, sys
p, name = sys.argv[1], sys.argv[2]; t = open(p, encoding="utf-8").read()
t = re.sub(r"^name:.*$", f"name: {name}", t, count=1, flags=re.M)
if not re.search(r"^name:", t, flags=re.M): t = t.replace("---\n", f"---\nname: {name}\n", 1)
t = re.sub(r"^model:.*$", "model: sonnet", t, count=1, flags=re.M)
t = re.sub(r"^tools:.*$", "tools: Read, Grep, Glob, Edit, Write, Bash, WebFetch", t, count=1, flags=re.M)
open(p, "w", encoding="utf-8").write(t)
PY2
    record agent "$name" "$url" "agents/$name.md"
    echo "    note: name/model/tools were converted for Claude; trim the tools list if the agent should do less" ;;

  hook)
    src="${1:?usage: fetch.sh hook <name|github-url>}"
    if [[ "$src" == http* ]]; then   # a single script from any repo
      url=$(raw_url "$src"); name=$(basename "$url")
      download "$url" "$lib/hooks/$name"; chmod +x "$lib/hooks/$name"
      record hook "$name" "$url" "hooks/$name"
      echo "    note: register it yourself in the project's .claude/settings.json (validate-bash.sh is an example)"
      exit 0
    fi
    # an awesome-copilot hook folder: download every file, then convert hooks.json for Claude
    dest="$lib/hooks/$src"
    [[ -e "$dest" ]] && { echo "  ! already in library: hooks/$src"; exit 1; }
    files=$(curl -fsSL "https://api.github.com/repos/github/awesome-copilot/contents/hooks/$src" 2>/dev/null \
      | python3 -Ic "import json,sys; [print(x['name']) for x in json.load(sys.stdin) if x['type']=='file']" 2>/dev/null) \
      || { echo "  ! no awesome-copilot hook named '$src' (try: fetch.sh browse hooks)"; exit 1; }
    mkdir -p "$dest"
    for f in $files; do curl -fsSL "$AC/hooks/$src/$f" -o "$dest/$f"; done
    chmod +x "$dest"/*.sh "$dest"/*.py 2>/dev/null || true
    # Copilot hooks.json -> claude-settings.json (Claude event names, Claude paths)
    python3 -I - "$dest" "$src" <<'PY3'
import json, os, sys
dest, name = sys.argv[1], sys.argv[2]
cp = json.load(open(os.path.join(dest, "hooks.json")))
events = {"sessionStart": "SessionStart", "sessionEnd": "SessionEnd", "userPromptSubmitted": "UserPromptSubmit",
          "preToolUse": "PreToolUse", "postToolUse": "PostToolUse", "agentStop": "Stop", "subagentStop": "SubagentStop"}
out = {}
for ev, entries in cp.get("hooks", {}).items():
    if ev not in events:
        print(f"    ! skipped event '{ev}': Claude Code has no equivalent"); continue
    for e in entries:
        script = os.path.basename(e.get("bash") or e.get("command", ""))
        env = "".join(f"{k}={v} " for k, v in (e.get("env") or {}).items())
        h = {"type": "command", "command": f'{env}"$CLAUDE_PROJECT_DIR"/.claude/hooks/{name}/{script}'}
        if e.get("timeoutSec"): h["timeout"] = e["timeoutSec"]
        out.setdefault(events[ev], []).append({"hooks": [h]})
json.dump({"hooks": out}, open(os.path.join(dest, "claude-settings.json"), "w"), indent=2)
print("    events: " + ", ".join(out))
PY3
    record hook "$src" "github/awesome-copilot hooks/$src" "hooks/$src/"
    echo "    note: written for Copilot. Read the script: tool hooks (Pre/PostToolUse) may expect Copilot's input format"
    echo "    note: new-project.sh registers it in the project's settings.json automatically" ;;

  inspect)
    repo=$(sed -E 's#^https?://github.com/##; s#\.git$##; s#/$##' <<<"${1:?usage: fetch.sh inspect <github-url|owner/repo>}" | cut -d/ -f1,2)
    curl -fsSL "https://api.github.com/repos/$repo/git/trees/HEAD?recursive=1" 2>/dev/null | python3 -I -c '
import json, sys, re
repo = sys.argv[1]
paths = [t["path"] for t in json.load(sys.stdin).get("tree", [])]
found = False; seen = set()
def say(kind, cmd):
    global found; found = True
    if cmd in seen: return
    seen.add(cmd); print(f"  {kind:12} {cmd}")
print(f"{repo} contains:")
if ".claude-plugin/marketplace.json" in paths:
    say("marketplace", f"bin/fetch.sh marketplace {repo}   (then: bin/fetch.sh browse plugins)")
elif ".claude-plugin/plugin.json" in paths:
    say("plugin", f"bin/fetch.sh marketplace {repo}   (single plugin; check its README for the install line)")
for p in paths:
    if p.endswith("/SKILL.md") or p == "SKILL.md":
        name = p.split("/")[-2] if "/" in p else repo.split("/")[1]
        say("skill", f"bin/fetch.sh skill {repo}@{name}")
for p in paths:
    if re.search(r"(^|/)\.?claude/agents/[^/]+\.md$|(^|/)agents/[^/]+\.md$", p):
        say("agent", f"bin/fetch.sh agent https://github.com/{repo}/blob/HEAD/{p}")
for p in paths:
    if re.search(r"(^|/)hooks/[^/]+\.(sh|py|js|ts)$", p):
        say("hook", f"bin/fetch.sh hook https://github.com/{repo}/blob/HEAD/{p}")
if not found:
    print("  nothing fetchable found: it is probably a standalone tool. Read its README for how to install it.")
' "$repo" 2>/dev/null || echo "  ! couldn't read github.com/$repo (wrong name, private, or GitHub rate limit: 60 lookups/hour)" ;;

  marketplace)
    repo="${1:?usage: fetch.sh marketplace <owner/repo>}"
    claude plugin marketplace add "$repo" && record marketplace "$repo" "github.com/$repo" "CATALOGUE.md"
    echo "    next: bin/fetch.sh browse plugins <word>, then bin/fetch.sh plugin <name@marketplace>" ;;

  plugin)
    id="${1:?usage: fetch.sh plugin <name@marketplace>}"
    [[ "$id" == *@* ]] || { echo "  ! use the form name@marketplace (copy it from 'fetch.sh browse plugins')"; exit 1; }
    touch "$lib/plugins.txt"
    grep -qxF "$id" "$lib/plugins.txt" && { echo "  ! already in library: $id"; exit 1; }
    echo "$id" >> "$lib/plugins.txt"
    record plugin "$id" "Claude plugin marketplace" "plugins.txt"
    echo "    note: plugins aren't copied; new-project.sh installs them into the project (plugins/$id)" ;;

  list)
    for d in skills agents rules hooks workflows; do
      echo "== $d =="; ls "$lib/$d" 2>/dev/null | sed 's/^/  /'
    done
    echo "== plugins =="; sed 's/^/  /' "$lib/plugins.txt" 2>/dev/null || true ;;

  *) sed -n '2,/^set/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//' ;;
esac
