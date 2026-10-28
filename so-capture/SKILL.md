---
name: so-capture
description: Capture problems, discoveries, decisions and gotchas from a coding session into structured draft records, then flush them to the team knowledge repo as a pull request (GitHub) or merge request (GitLab) for review before publication, wherever this machine's config says the team's repos live. Use whenever the user says "capture this", "note this", "remember this for the team", "this is a gotcha", "write this up", "/capture", or asks to flush, list, or review pending captures — and proactively offer a capture when a session hits a hard-won fix, a surprising platform behaviour, or a decision with trade-offs, even if the user doesn't ask.
user-invocable: true
---

# so-capture

Turns session knowledge into team knowledge without letting half-baked notes escape.
Three verbs: **capture** (local draft), **flush** (open a PR or MR), **list** (show pending).
Publication is never automatic — merge is the gate.

## Step 0 — Data gate (ask every time, never assume)

This skill writes to the team's git host (GitHub or GitLab, from the config below) and may read a
token from the environment.
Before the first capture in a session, confirm the target repo is the team knowledge
repo, which is the canon (the standards repository; captures land under `captures/` there). The one content rule is Guidebook §9.2: a credential never enters a record, a
log or a handoff. Never embed hostnames, project IDs, account identifiers, key paths
or tokens in this skill or in any record. All routing comes from config at runtime.

## Config (read at runtime, never hardcoded)

What differs between worlds (home and work) lives in the machine's one config, `~/.ds/config.toml`.
canon's `install.sh` writes it once it knows the team host; edit it there, never here:

```toml
[world]
host      = "github"         # github or gitlab
group     = "<group URL>"    # https://<host>/<group>; the knowledge repo is <group>/<repo>
token_env = ""               # gitlab: the NAME of the variable holding a token, never the value;
                             # github: empty, gh's own login is used

[capture]
repo   = "canon"             # the knowledge repo, under group
branch = "main"
dir    = "captures"          # path inside the knowledge repo
```

Look it up in this order and say which one you used:

1. `[world]` and `[capture]` in `~/.ds/config.toml`.
2. The older `~/.config/so-capture/config.toml`, if it exists (`knowledge_repo`, `default_branch`,
   `captures_dir`, `token_env`; the host from `GITLAB_HOST`): a GitLab world.
3. Neither: the canon checkout's remote (`git -C "${DS_CANON:-$HOME/Developer/canon}" remote get-url
   origin`) gives the host and the repo; `branch = "main"`, `dir = "captures"`.

Drafts stay in the repo being worked on, in `.ds/captures/`, the folder ds-next's `capture` tool
writes to as well. Nothing found, or no token where one is needed: say so, keep the drafts local,
and do not fail the capture.

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
4. **Write** to `.ds/captures/YYYY-MM-DD-<slug>.md` with `status: draft`.
   Ensure `.ds/captures/` is in `.gitignore`; add it if not.
5. **Confirm** in ≤2 lines: type, title, file path. Do not restate the record.

Rules: one record per distinct thing — never merge two discoveries into one file.
Never edit an existing record's `id`. Never write a record with an empty Summary.

## list

Print pending drafts: filename, type, title, age. No content. Offer `flush` if any
are older than a day.

## flush

Trigger: user asks, or the session-end prompt (see Hook) gets a yes.

1. Read every record in `.ds/captures/` (not `flushed/`): this skill's own `status: draft`
   records, and the canon-shaped drafts ds-next's `capture` tool writes (front matter `id`,
   `status: proposed`), which go through the same quality pass.
2. **Quality pass** — this is the "no half-baked notes" step. For each record check:
   - Summary readable without session context? Resolution actionable? Evidence
     present and scrubbed? Tags non-empty?
   - Anything failing → show the record and ask the user to fix, skip, or drop it.
     Never silently promote a weak record.
3. Clone or fetch the knowledge repo (`<group>/<repo>`) into a temp dir (shallow). Branch
   `capture/<date>-<short-id>` from `branch`.
4. Copy records into `<dir>/`; set this skill's records to `status: flushed` (ds-next's drafts keep
   `status: proposed`, so they can still become standards); commit one record per commit with
   message `capture(<type>): <title>`.
5. Push the branch and open the review, opened as a draft when any record has a non-empty Open.
   Title `Captures: <n> from <repo> (<date>)`; description: the titles as a checklist.
   - `host = "github"`: `gh pr create --repo <owner>/<repo> --base <branch> --head <branch name>`
     (`--draft` as above), with gh's own login.
   - `host = "gitlab"`: `glab mr create` when glab is logged in to that host, else the GitLab API
     with the token in `$<token_env>`.
6. Move flushed records to `.ds/captures/flushed/`. Print the PR or MR URL only.

If the push or the PR/MR fails, leave the records where they are and report the error verbatim.
No retries that could duplicate branches, PRs or MRs.

## Hook (optional, install separately)

A session-end / pre-compact hook that runs `list` and, if drafts exist, asks:
"N unflushed captures — flush now?" It never flushes on its own. See
`references/hook.md` for the hook body and install note.

## Downstream (not this skill's job, documented for context)

Merge in the canon triggers CI: rebuild `index.json`; later, render the portal to SPCS and
load merged records into a Snowflake table → refresh the Cortex Search service.
A future `so-recall` skill searches that service before starting work.

A `decision` or `discovery` capture that generalizes beyond its repo is a candidate standard:
propose it with `/so-changes insight`, which writes a `proposed` standard in the canon.

## Out of scope

Editing published records (do it in the knowledge repo), posting to Slack,
auto-detecting captures from every turn, anything that publishes without a PR or MR.
