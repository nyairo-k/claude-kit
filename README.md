# Claude Code project kit

## Install (one line, needs only curl and tar)

    curl -fsSL https://raw.githubusercontent.com/nyairo-k/claude-kit/main/install.sh | bash

Installs to `~/claude-kit` and puts the `kit` command on your PATH. Then `kit fetch`, `kit new`, `kit link`, `kit update`.
The longer forms below (`bin/fetch.sh` etc.) still work too.

```
template/   the folder structure, copied into every new project
library/    your permanent collection of skills, agents, rules, hooks and workflows
bin/        helper scripts
```

## Start a new project (or add the structure to an existing one)
    bin/new-project.sh ~/code/my-app                         # structure only
    bin/new-project.sh ~/code/my-app skills/wrangler        # + library items
Existing files are never overwritten. Then run `claude` in the project and type `/init`.

## Grow the library (only downloads what you name)
    bin/fetch.sh find cloudflare                    # search all public skills
    bin/fetch.sh skill cloudflare/skills@wrangler   # save one into library/skills/
    bin/fetch.sh browse rules python                # list awesome-copilot rules
    bin/fetch.sh rule <name>                        # save one into library/rules/
    bin/fetch.sh agent <name|github-url>            # then fix its tools: line
    bin/fetch.sh browse hooks                       # list hooks
    bin/fetch.sh hook <name>                        # save one (registered automatically by new-project.sh)
    bin/fetch.sh browse claude security             # search awesome-claude-code (249 projects)
    bin/fetch.sh inspect <github-url>               # what's inside a project + how to fetch it
    bin/fetch.sh marketplace <owner/repo>           # add a plugin collection
    bin/fetch.sh list                               # what you have
Every fetch is recorded in library/CATALOGUE.md (what, where from, when).

## Skills you want everywhere (no copying)
    bin/link-global.sh skills/wrangler
Symlinks into ~/.claude/skills/, so the skill works in every project, and
library edits show up everywhere.

**Rule of thumb:** generic tools (commit messages, README writing, reviewer
agents) go global. Stack-specific ones (Cloudflare, Next.js, deploy) get
copied into the projects that use them.
