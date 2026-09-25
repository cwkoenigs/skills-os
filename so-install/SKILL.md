---
name: so-install
description: "Install the skills-os collection into a local agent runtime — links every so-* skill from a skills-os checkout into Claude Code (~/.claude/skills) and Codex (~/.codex/skills) so the runtime can see them, then verifies each link resolves. Use on a fresh machine, after cloning skills-os, when /so-* commands are missing, when a new so-* skill was added to the repo, or when checking whether the installed skills are in sync with the checkout. Triggers: so-install, install skills-os, install our skills, install so-skills, set up skills-os on this machine, link skills, skills not showing up, /so- commands missing, refresh installed skills, uninstall skills-os."
user-invocable: true
---

# so-install (link skills-os into a runtime)

A `so-<name>/SKILL.md` sitting in a git checkout does nothing on its own. Claude Code only loads
skills it finds under `$HOME/.claude/skills/` (or a project's `.claude/skills/`); Codex only loads
skills under `$HOME/.codex/skills/`. This skill bridges that gap by **symlinking** each skill folder
from the checkout into those directories.

Symlinks rather than copies, deliberately: the checkout stays the single source of truth, so a
`git pull` or a local edit is live immediately and there is no second copy to drift. The cost is
that the checkout must stay where it is; moving it breaks the links (re-run this skill to fix).

`install.sh` in the repo is **not** this. It registers a remote source in a `skills.json` manifest,
which neither Claude Code nor Codex reads. Leave it alone; use this skill for local runtimes.

## Prerequisites

- A local skills-os checkout. Resolve its path first: if the current directory is inside it,
  `git rev-parse --show-toplevel`; otherwise ask the user (typical: `$HOME/code/skills-os`).
- At least one runtime present: `$HOME/.claude/` (Claude Code) and/or `$HOME/.codex/` (Codex).

## Workflow

### Step 1: Derive the skill list from the checkout

Never hardcode the names; the collection changes. Every `so-*/` directory containing a `SKILL.md`
is a skill:

```bash
cd <skills-os-checkout>
./install.sh --list          # default set; excludes OPTIONAL skills
./install.sh --list --all    # includes so-codex-review
```

`so-codex-review` is optional because it shells out to the Codex CLI. Include it only when
`command -v codex` succeeds; linking it without the CLI gives the user a skill that fails on
first use.

### Step 2: Detect runtimes

Check for each runtime's home directory. Create the skills subdirectory if the runtime exists but
the subdirectory does not; do **not** create a runtime home that is absent, since a directory the
runtime never reads looks like success while doing nothing.

| Runtime | Presence check | Skills directory |
|---|---|---|
| Claude Code | `[ -d "$HOME/.claude" ]` | `$HOME/.claude/skills/` |
| Codex | `[ -d "$HOME/.codex" ]` | `$HOME/.codex/skills/` |

Tell the user which runtimes were found. If neither, stop and say so.

### Step 3: Link

For each runtime found and each skill in the list, look before writing. If `<skills-dir>/<skill>`
already exists and is a **real directory** rather than a symlink, do not replace it; report it and
let the user decide, since it may hold a local edit they have not pushed. Otherwise:

```bash
ln -sfn "<skills-os-checkout>/<skill>" "<skills-dir>/<skill>"
```

`-sfn` replaces an existing link in place, so re-running is a refresh rather than an error, and
`-n` keeps it from following an existing link into the target.

### Step 4: Verify

A dangling link is the failure mode to catch here. For each link, confirm it resolves and that the
target's `SKILL.md` declares the same name as the folder; a mismatch means the link points at the
wrong skill:

```bash
for s in <skills-dir>/so-*; do
  n=$(basename "$s")
  got=$(sed -n 's/^name: //p' "$s/SKILL.md" 2>/dev/null | head -1)
  [ "$got" = "$n" ] && echo "OK   $n" || echo "FAIL $n (resolved name: '${got:-<none>}')"
done
```

Claude Code picks up new skills on `/skills` or a restart; Codex on restart. Say so.

### Step 5: Report

One short list per runtime: linked, refreshed, skipped (with reason: optional and CLI absent, or
real directory in the way). Nothing else.

## Uninstall

Remove the links only; the checkout is untouched:

```bash
for s in $(<skills-os-checkout>/install.sh --list --all); do
  rm -f "$HOME/.claude/skills/$s" "$HOME/.codex/skills/$s"
done
```

`rm -f` on a symlink removes the link, not the target. Never `rm -r` here: on a link that
resolved, that would delete the skill out of the checkout.

## Output

Every default `so-*` skill (plus `so-codex-review` when the Codex CLI is present) linked into each
detected runtime's user-level skills directory, verified to resolve, and a per-runtime summary of
what changed.
