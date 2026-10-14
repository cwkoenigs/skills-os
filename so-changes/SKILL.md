---
name: so-changes
description: "Record decisions (ADRs), log shipped changes (changelog), draft stakeholder communications, and capture cross-project insights. Use when: recording a decision, logging what shipped, drafting an announcement, updating the changelog, cutting a release, or documenting a cross-project pattern. Triggers: so-changes adr, so-changes changelog, so-changes announce, so-changes release, so-changes insight, record decision, what changed, draft announcement, changelog entry, architecture decision, communicate update, notify stakeholders, cut a release, cross-project pattern."
user-invocable: true
---

# so-changes (ADR + Changelog + Announce + Release + Insight)

Record decisions, log changes, communicate updates. One skill, five modes. Implements Guidebook §3
(Decision Logs and Lineage) and §14.1 (ADR template).

## Intent Detection

| Intent | Triggers | Go To |
|---|---|---|
| ADR | "adr", "record decision", "why did we", "architecture decision", "document this choice" | Step 1 |
| CHANGELOG | "changelog", "log this change", "what shipped", "update changelog" | Step 2 |
| ANNOUNCE | "announce", "draft communication", "notify stakeholders", "who needs to know" | Step 3 |
| RELEASE | "cut a release", "ship version", "release v" | Step 4 |
| INSIGHT | "insight", "cross-project pattern", "promote to insight" | Step 5 |

If the request plausibly matches two modes, ask once which one.

## Step 0: Scaffold Check (run FIRST, every time)

First, is this repository in the knowledge system? If `.ds/manifest.toml` exists, local decisions
live in `DECISIONS.md` (written by `ds new`) and org-wide decisions are standards in the canon;
do not scaffold `docs/adr/` or `docs/insights/` in such a repo. Otherwise, legacy layout applies.

Check whether `docs/adr/`, `docs/decisions/`, and `CHANGELOG.md` exist in the project root. If
missing, create only what the current mode needs:

1. `docs/adr/` with `000-template.md` (see ADR Template below).
2. `docs/decisions/` for cadence decision logs (Guidebook §3).
3. `docs/communications/` for announcement drafts.
4. `CHANGELOG.md` with a keep-a-changelog header:
   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.

   The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

   ## [Unreleased]
   ```

Tell the user what you initialized. Do not scaffold directories the mode will not write to.

## Step 1: ADR (Architecture Decision Record)

### 1a: Gather context
Establish, from the conversation where possible rather than by interrogation:
- The decision being recorded, in one sentence.
- The problem and the constraints that mattered.
- The options considered and why the losers lost. **An ADR with one option is not a decision
  record** — if there was genuinely no alternative, say so explicitly and note why.
- Consequences: positive, negative, operational, security, cost, maintenance.
- How you will know the decision worked (validation).

### 1b: Number and write
**Repo in the knowledge system (`.ds/manifest.toml` exists):** the decision is repo-local, so it
goes in `DECISIONS.md` as a section `## local-NNN: <Decision title>` (next integer after the highest
`local-NNN` present), with the same fields as the ADR Template below. Replace the file's
"None yet." line on the first decision. If the decision is really org-wide, it is a standard, not a
local ADR: go to Step 5 and propose it to the canon instead.

**Legacy repo:** find the highest existing `NNN-` prefix in `docs/adr/` and use the next integer,
zero-padded to 3. Write `docs/adr/<NNN>-<kebab-slug>.md` using the ADR Template. Status starts
`Accepted` when the decision is already made, `Proposed` when it needs sign-off.

### 1c: Chain offer
Offer once: log a CHANGELOG entry (Step 2), draft an announcement (Step 3), or stop.

## Step 2: Changelog

### 2a: Drift check (run first, before drafting anything)
Compare `CHANGELOG.md`'s newest entries against recent git history (`git log --oneline -20`). If
shipped work is missing from the changelog, say so and offer to backfill before adding the new
entry. Do not silently add one entry on top of a stale file.

### 2b: Determine change type
Classify into keep-a-changelog sections: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`,
`Security`. One entry may span two sections; do not force it into one.

### 2c: Draft entry
Write for the reader who did not do the work: what changed and what it means for them, not the
implementation detail. Include the MR/PR or commit reference. Flag **user-visible behavior changes**
explicitly (Guidebook §2.4) — those are the ones that surprise people.

### 2d: Write to CHANGELOG.md
Insert under `## [Unreleased]` in the correct section, creating the section if absent. Preserve
existing entries and formatting.

### 2e: Chain offer
Offer once: draft an announcement (Step 3), cut a release (Step 4), promote a pattern to an insight
(Step 5), or stop.

## Step 3: Announce

### 3a: Determine audience
Ask who needs to know, and infer the register from the answer: direct teammates, a wider
engineering group, or non-technical stakeholders. The same change gets three different drafts.

### 3b: Source material
Pull from the changelog entry, the ADR, and the decision log if they exist. Do not re-interview for
facts already recorded.

### 3c: Draft communication
Structure: what changed → why it matters to *this* audience → what they need to do (or explicitly
"no action needed") → where to ask questions. Lead with impact, not chronology. Keep the length
proportional to the change; a one-line fix does not need five paragraphs.

### 3d: Save and present
Write to `docs/communications/<YYYY-MM-DD>-<slug>.md` and show the draft in conversation so it can
be copied. Do not send anything anywhere.

## Step 4: Release (cut a version)

### 4a: Confirm unreleased content exists
If `## [Unreleased]` is empty, stop and say so. Do not cut an empty release.

### 4b: Determine version number
Read the last released version and propose the next one by semver, justified by the unreleased
content: breaking change → major; new feature → minor; fixes only → patch. Ask for confirmation —
the version number is the user's call.

### 4c: Cut the release
1. Rename `## [Unreleased]` to `## [<version>] - <YYYY-MM-DD>`.
2. Insert a fresh empty `## [Unreleased]` above it.
3. Report the version and date. Do **not** create a git tag or push unless the user asks.

### 4d: Chain offer
Offer once: draft a release announcement (Step 3), or stop.

## Step 5: Insight (cross-project pattern)

Use when a lesson generalizes beyond the project that produced it — a pattern worth applying
elsewhere, not a change log entry.

### 5a: Gather the pattern
- The pattern, in one sentence.
- The evidence: the concrete cases that produced it (at least two — one case is an anecdote).
- What to do about it: the actionable rule.

### 5b: Draft the insight
**With a canon available** (`$DS_CANON` or `../canon` has `index.json`): an insight that generalizes
is a proposed standard. Write `<canon>/<kebab-id>.md` with front matter `id`, `version: 1`, `title`,
`applies_to` (tags, or `["*"]`), `owner`, `status: proposed`, and `date`; put the pattern, evidence,
and rule below it, and an `## Apply` section when there is a mechanical step. Run
`python scripts/build_index.py` in the canon and open a merge request there. Do not push without
asking. Skip 5d: the canon's owner review is the promotion.

**Without a canon:** write `docs/insights/<kebab-slug>.md`:

```markdown
# <Insight title>

## The pattern
<one paragraph>

## Evidence
- <case 1 — repo/date/what happened>
- <case 2 — ...>

## What to do about it
<the actionable rule>
```

### 5c: Human-glance gate
**⚠️ STOP:** Show the draft and get confirmation before writing. Insights become team guidance; a
wrong one is worse than none.

### 5d: Promote if it is really a standard
If the insight is a rule the team should be held to rather than a note, it belongs in
`shared/guidebook.md`, not `docs/insights/`. Say so and offer to route it through `/so-skills`
(which owns guidebook changes and the `build.sh` regeneration that follows).

## ADR Template

```markdown
# ADR-<NNN>: <Decision title>

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-<NNN>

## Date
YYYY-MM-DD

## Context
What problem are we solving? What constraints matter?

## Options Considered
1. **<Option A>** — <why it lost, or "chosen">
2. **<Option B>** — <why it lost>

## Decision
What did we decide?

## Consequences
Positive, negative, operational, security, cost, maintenance.

## Validation
How will we know the decision worked?

## Review Date
YYYY-MM-DD
```

## Notes

- **Never invent history.** If you cannot establish what happened from the conversation, git, or the
  existing docs, ask. A plausible-sounding fabricated ADR is a liability.
- **One artifact per invocation.** Chain offers are offers; do not write four files because the modes
  are adjacent.
- Guidebook §3 owns the decision-log format used by the cadence skills; this skill owns ADRs,
  changelog, announcements, releases, and insights. They are complementary, not duplicates.

## Output

One of: a numbered ADR, a changelog entry, a saved announcement draft, a cut release, or an insight
doc — plus a single chain offer.
