---
name: so-capture
description: Capture problems, discoveries, decisions and gotchas from a coding session into structured draft records, then flush them to the team knowledge repo as a GitLab MR for review before publication. Use whenever the user says "capture this", "note this", "remember this for the team", "this is a gotcha", "write this up", "/capture", or asks to flush, list, or review pending captures — and proactively offer a capture when a session hits a hard-won fix, a surprising platform behaviour, or a decision with trade-offs, even if the user doesn't ask.
---

<!-- vendored: shared/guidebook.md, shared/cadence-core.md (build.sh) -->

# so-capture

Turns session knowledge into team knowledge without letting half-baked notes escape.
Three verbs: **capture** (local draft), **flush** (open MR), **list** (show pending).
Publication is never automatic — merge is the gate.

## Step 0 — Data gate (ask every time, never assume)

This skill writes to a GitLab remote and reads a token from the environment.
Per `AGENTS.md`: internal-only review track. Before the first capture in a session,
confirm the target repo is the team knowledge repo and that nothing in the record
is restricted data. Never embed hostnames, project IDs, account identifiers, key
paths or tokens in this skill or in any record. All routing comes from config at runtime.

## Config (read at runtime, never hardcoded)

`~/.config/so-capture/config.toml` (create if absent, ask the user for values):

```toml
knowledge_repo = "<group/project slug>"   # slug only; host comes from GITLAB_HOST
default_branch = "main"
captures_dir   = "captures"               # path inside knowledge repo
local_stage    = ".captures"              # relative to cwd; gitignored
token_env      = "GITLAB_TOKEN"           # name of env var, not the value
```

Missing config or token → say so, keep the draft local, do not fail the capture.

## capture

Trigger: user asks, or you judge the moment worth offering (see description).
If offering, ask in one line — "Worth capturing as a gotcha?" — and move on if declined.

1. **Classify** the type. If unclear, ask once with the five options; default `discovery`.
2. **Draft** using `assets/capture-template.md`. Populate from the session:
   - `repo`/`ref` from `git remote` (slug only) and `git rev-parse`.
   - Evidence from the actual error/query/diff in context, trimmed to the minimum
     that reproduces or proves the point.
   - "What was tried" only for `problem`/`gotcha`; include dead ends.
   - Summary must stand alone for a reader with no session context.
3. **Scrub** before writing: remove tokens, account locators, internal hostnames,
   absolute machine paths, PII. Replace with `<redacted>` and note it in Open if it
   matters to the record.
4. **Write** to `<local_stage>/YYYY-MM-DD-<slug>.md` with `status: draft`.
   Ensure `<local_stage>` is in `.gitignore`; add it if not.
5. **Confirm** in ≤2 lines: type, title, file path. Do not restate the record.

Rules: one record per distinct thing — never merge two discoveries into one file.
Never edit an existing record's `id`. Never write a record with an empty Summary.

## list

Print pending drafts: filename, type, title, age. No content. Offer `flush` if any
are older than a day.

## flush

Trigger: user asks, or the session-end prompt (see Hook) gets a yes.

1. Read every `status: draft` record in `<local_stage>`.
2. **Quality pass** — this is the "no half-baked notes" step. For each record check:
   - Summary readable without session context? Resolution actionable? Evidence
     present and scrubbed? Tags non-empty?
   - Anything failing → show the record and ask the user to fix, skip, or drop it.
     Never silently promote a weak record.
3. Clone or fetch the knowledge repo into a temp dir (shallow). Branch
   `capture/<date>-<short-id>` from `default_branch`.
4. Copy records into `<captures_dir>/`, set `status: flushed`, commit one record
   per commit with message `capture(<type>): <title>`.
5. Push and open an MR via the GitLab API using `$<token_env>`. MR title:
   `Captures: <n> from <repo> (<date>)`. Description: the titles as a checklist.
   MR is opened as a draft when any record has non-empty Open.
6. Move flushed records to `<local_stage>/flushed/`. Print the MR URL only.

If push or MR creation fails, leave records as `draft` and report the error verbatim.
No retries that could duplicate branches or MRs.

## Hook (optional, install separately)

A session-end / pre-compact hook that runs `list` and, if drafts exist, asks:
"N unflushed captures — flush now?" It never flushes on its own. See
`references/hook.md` for the hook body and install note.

## Downstream (not this skill's job, documented for context)

Merge in the knowledge repo triggers CI: build the docs site → deploy to SPCS;
load merged records into a Snowflake table → refresh the Cortex Search service.
A future `so-recall` skill searches that service before starting work.

## Out of scope

Editing published records (do it in the knowledge repo), posting to Slack,
auto-detecting captures from every turn, anything that publishes without an MR.
