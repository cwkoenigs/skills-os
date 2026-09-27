# so-capture — session kickoff

Read this whole file, then start at **Phase 1**. Do not re-litigate the decisions in
"Decisions made"; they were settled deliberately. Ask only where "Open" says to.

## What we are building

A way to capture problems, discoveries, decisions and gotchas *during* a coding
session and get them to the team without half-baked notes escaping.

```
session ──capture──▶ .captures/*.md (local drafts, gitignored)
                          │
                        flush ──▶ MR on team knowledge repo (GitLab)  ◀── the quality gate
                          │
                        merge ──▶ CI: build docs site → deploy to SPCS
                                  CI: load records → Snowflake table → Cortex Search
                                                                        │
                                            future so-recall ◀──────────┘
```

Files already drafted in `so-capture/`:

| File | What it is |
|---|---|
| `SKILL.md` | The skill: data gate, runtime config, `capture` / `list` / `flush` |
| `assets/capture-template.md` | The record schema, one file per capture |
| `references/hook.md` | Session-end reminder hook — asks to flush, never flushes |

## Decisions made (don't reopen)

- **Source of truth is markdown in a GitLab knowledge repo.** Not a board, not a
  Snowflake table first. The MR is the review gate; merge is publication.
- **Captures stage locally, never post directly.** Offline-safe, reviewable, cheap to drop.
- **Capture is user-triggered** (plus a low-friction offer from Claude at obvious
  moments). No per-turn auto-detection — it produces noise.
- **The hook only reminds.** Auto-flush would defeat the gate.
- **Snowflake is the read side**: SPCS hosts the site; a table + Cortex Search makes
  the corpus queryable by teammates and by future agent sessions. This is what makes
  the thing compound instead of being a shared diary.
- **Static site first** (MkDocs Material unless a reason appears). Live-from-table
  Next app is a later option, not the start.
- **No hostnames, project IDs, account locators, tokens or key paths** anywhere in
  the skill or records. Config lives in `~/.config/so-capture/config.toml`; the token
  comes from an env var named in that config. Internal-only review track per
  skill-os `AGENTS.md`.

## Phase 1 — Install the skill into skill-os

1. Copy `so-capture/` into the skill-os repo alongside the other `so-*` skills.
2. Follow `so-skills` (the authoring entrypoint) as if this were a new skill:
   data gate → dedup check against existing `so-*` → wire `build.sh` so the
   guidebook/cadence-core vendoring marker at the top of `SKILL.md` matches what
   `build.sh` actually keys on → register in README table → `tests/verify.sh`.
3. Fix whatever verify.sh flags. Do not add machine paths to satisfy it.
4. Commit: `feat(so-capture): capture/list/flush skill`.

## Phase 2 — Make `capture` and `list` work locally

1. Implement config loading; on first run with no config, prompt for `knowledge_repo`
   slug and `token_env` name, write the file, continue.
2. Implement `capture`: classify → draft from template → scrub → write to
   `.captures/` → ensure `.gitignore` entry → 2-line confirmation.
3. Implement `list`.
4. **Test by using it in this session**: capture two things from doing Phase 1
   (there will be at least one gotcha). Check the records read standalone.
   Keep those two records — they are the seed content for the knowledge repo.

## Phase 3 — `flush` against a real repo

1. Create the knowledge repo on GitLab (`captures/` dir, MkDocs skeleton, README
   explaining the schema). Name is the user's call — **ask**.
2. Implement `flush`: quality pass (show weak records back, never auto-promote) →
   shallow clone to tmp → branch `capture/<date>-<id>` → one commit per record →
   push → MR via API using `$<token_env>` → move to `.captures/flushed/` → print URL.
3. Failure = leave drafts as `draft`, print the error, no retries that could
   duplicate branches/MRs.
4. Flush the two seed records. Merge the MR by hand. That is the first published content.

## Phase 4 — Hook

1. Install `references/hook.md`'s script under the session-end event for the
   platform in use (Claude Code `Stop`; find Cortex Code's equivalent — **do not guess**).
2. Verify it prints the reminder with a draft present and stays silent without one.

## Phase 5 — Downstream (separate repo, can be a separate session)

In the knowledge repo, one CI pipeline on merge to `default_branch`:

1. `mkdocs build` → container (nginx + static) → push to the Snowflake image repo →
   `ALTER SERVICE` on SPCS. Reuse existing SPCS deployment patterns from the
   platform work; don't invent a new one.
2. Parse `captures/*.md` front matter + body → `MERGE INTO` a table
   (`id` as key; columns for the front matter fields plus `body`) → refresh the
   Cortex Search service over `title`, `summary`, `body`, `tags`.
3. Site link + search service name go in the knowledge repo README, not in the skill.

## Open — ask the user

- Knowledge repo name and GitLab group.
- Whether `question`-type captures should open the MR as draft (currently: yes, if
  `Open` is non-empty) or always land as normal.
- Cortex Code hook event name, if that platform is in scope now.

## Done looks like

`capture this` mid-session → 2-line confirmation. Session ends → reminder. `flush` →
MR URL. Merge → site updated on SPCS, record findable via Cortex Search. Two real
records published by the end of Phase 3.
