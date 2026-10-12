#!/usr/bin/env bash
# PreToolUse hook for Bash: blocks dangerous commands.
# Exit 2 = block the command and show stderr to Claude.
cmd=$(python3 -c 'import json,sys; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))')

blocked=(
  'rm -rf /'
  'rm -rf ~'
  'git push --force'
  'git push -f'
  'git reset --hard'
  'DROP TABLE'
  'mkfs'
  ':(){ :|:& };:'
)
for pat in "${blocked[@]}"; do
  if [[ "$cmd" == *"$pat"* ]]; then
    echo "Blocked by .claude/hooks/validate-bash.sh: command contains '$pat'. Ask the user to run it manually if it is really needed." >&2
    exit 2
  fi
done
exit 0
