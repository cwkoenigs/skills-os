---
name: so-skills
description: "The root wrapper for ALL skill work — the front door over the native skill-development skill. Use whenever creating, summarizing a session into, auditing, refactoring, or compiling a skill in this repo. Wraps native skill-development and adds the repo layer: so- naming, README/install.sh registration, build.sh wiring, an auto best-practice audit, and external review. Triggers: so-skills, build skill, new skill, create team skill, add a skill, audit skill, refactor skill, compile skill, summarize session into skill, contribute to skill-os."
user-invocable: true
---

# so-skills (skill-os wrapper)

The root front door for all skill work. It **wraps** the native `skill-development` skill — which
already encompasses create / summarize / audit / refactor / compile — and layers this repo's
conventions, alignment gates, and registration steps on top. It does **not** reimplement authoring;
the native skill owns the mechanics.

Guidebook §8.2 requires new/changed skills be authored via the native gate; this wrapper *is* that
gate for this repo, plus the repo glue the native skill can't know about.

## Setup

1. **Load** the native authoring standard: invoke `$skill-development` and load its
   `SKILL_BEST_PRACTICES.md` (canonical structure, conciseness, red flags). Do not
   duplicate it here.
2. **Point to** `shared/cadence-core.md` (shipped alongside this skill as `cadence-core.md`) for the
   change cadence. This skill applies it lightweight; load the full cadence only for material
   work.
3. **Confirm** you are working in the `skill-os` repo (skills live at repo root as
   `<name>/SKILL.md`). If not, ask the user for the repo path.

## Workflow

### Step 1: Detect intent (detection-first, ask only if ambiguous)

Read the user's request and route. Do **not** show a menu unless the intent is genuinely unclear.

| Intent | Triggers | Native sub-skill to follow |
|--------|----------|----------------------------|
| CREATE | "create/new/build skill" | `create-from-scratch` |
| SUMMARIZE | "summarize session", "capture this workflow", "turn into a skill" | `summarize-session` |
| AUDIT | "audit/review/lint skill" | `audit-skill` |
| REFACTOR | "refactor/restructure/decompose skill" | `refactor-skill` |
| COMPILE | "compile/speed up skill", "fast path", "make deterministic" | `compile-skill` |

Intents are mutually exclusive per run. If the request names an intent, proceed. If two plausibly
apply (e.g. "clean up so-changes" → audit or refactor?), ask once which one.

### Step 2: Dedup / native-first check (avoid bloat — Guidebook §1.2, §8.2)

Before creating anything new, confirm the need is not already met:
- **Native skills** — is there a bundled skill in the agent runtime that already covers the
  mechanics? Prefer composing over rebuilding.
- **Existing skills in this repo** — scan the README skills table / directories for overlap. If an
  existing skill is close, prefer AUDIT or REFACTOR over a new skill.

If a new skill is redundant, tell the user and recommend the composable alternative before
continuing.

### Step 3: Delegate the mechanics to native skill-development

Invoke the native skill with `$skill-development`; it routes **internally** to the sub-skill named
in Step 1 (you don't invoke `create-from-scratch` etc. directly). Follow it for the actual work
(structure, frontmatter, workflow steps, stopping points, compile eval design). Honor its stopping
points. The repo hooks in Step 6 are separate skills, invoked as `/so-best-practice-audit` and
`/so-codex-review`. This wrapper adds only the repo layer below — it does not restate native
guidance.

### Step 4: Apply repo conventions

- **Name:** `so-` prefix, kebab-case (e.g. `so-changes`), unique in the repo skills table.
- **Location:** repo root `<name>/SKILL.md`. Extra files (references/, examples.md) in the same
  folder.
- **No auxiliary docs** inside the skill folder (no README/CHANGELOG/audit-report) — SKILL.md +
  references only. Audit *outputs* are conversation artifacts, not committed files; committing one
  ships it to every installer for no benefit.
- **Description:** action-oriented, trigger-rich, in YAML frontmatter (native best-practices apply).
- **No machine-specific paths** — no `/Users/<name>/...`, no personal directories. Use `$HOME` or a
  `<placeholder>`. `tests/guard_no_machine_paths.sh` enforces this.

### Step 5: Wire shared sources (only if the skill consumes them)

If the skill embeds `shared/guidebook.md` or `shared/cadence-core.md` content (like this skill and
the interview skills do), it must install self-contained:
1. Add the skill name to the appropriate consumer list in `build.sh` (`CADENCE_CONSUMERS` for
   cadence-core; `GUIDEBOOK_CONSUMER` for the guidebook).
2. Run `./build.sh` and **commit the generated copy** — a bare pointer to a repo-root file will not
   co-install when the skill is fetched by name.

Never hand-edit a generated copy; edit the `shared/` source and re-run `./build.sh`.
`./tests/guard_generated_copies.sh` catches a drifted copy.

Skills that only *invoke* another skill (e.g. `/so-codex-review`) need no wiring — just
reference it.

### Step 6: Auto best-practice audit + review gate

1. **Auto-run** `/so-best-practice-audit` on the drafted/changed skill. Surface its findings and
   resolve High/Medium flags before commit. This keeps skills aligned to the guidebook
   automatically.
2. **External review:** ask the developer to confirm before routing the skill diff through
   `/so-codex-review` — do not invoke automatically. On explicit yes, apply its prescribed fixes;
   re-review only if a fix adds new scope. On no or no response, keep review internal.

**⚠️ STOP**: Present audit + review results and get approval to proceed to registration
(Step 7).

### Step 7: Register the skill

On approval, make the skill discoverable for teammates:
1. **README.md** skills table — add a row.
2. **install.sh** — no edit needed. The install list is **derived from the filesystem** (`so-*/`
   directories containing a `SKILL.md`), so creating the folder is the registration. Verify with
   `./install.sh --list`.

If a skill should be excluded from the default install (like `so-codex-review`), add it to the
`OPTIONAL` list in `install.sh` and note it in the README.

### Step 8: Validate, then commit

1. Verify SKILL.md is < 500 lines and the router stays thin. If it's over, move detail into
   `references/` rather than shipping an oversized router.
2. Run `./tests/verify.sh` — all six checks, one exit code. Report the result; do not claim success
   without running it.
3. If shared sources were wired, confirm `./build.sh` ran and the generated copies are staged.

**⚠️ STOP**: Final review — get explicit approval before committing.

4. On approval, commit the skill files together with any generated copies.
5. Push only when the user explicitly asks — never merge or push unprompted.

## Stopping Points

- ✋ Step 1: If intent is ambiguous, confirm which one.
- ✋ Step 6: After audit + review, before registering.
- ✋ Step 8: Final review, before committing.

## Output

A registered, guidebook-aligned `so-<name>/SKILL.md` in the `skill-os` repo — authored via the
native gate, audited, externally reviewed when the track is clear, wired into `build.sh` if it
consumes shared sources, and discoverable in the README table.
