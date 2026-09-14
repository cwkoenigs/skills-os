# Review Cadence Core

Shared **operational profile** of the Software Project Best Practices Guidebook, for
interview-driven change workflows (features **and** bug fixes). The **guidebook
(`shared/guidebook.md`) is the canonical source** for the underlying policy (restricted-data gate,
review track, decision-log template, phase format, rollout safety); this file cites it inline as
`Canonical: Guidebook §X` and carries only what the cadence skills execute at runtime **plus** the
operational mechanics the guidebook does not cover (external-review gate delegation, classification
corroboration, field-tested learnings). **When shared policy changes, edit the guidebook first, then
reconcile the operational restatement here.**

Each skill supplies its own **interview** and **phased plan**; everything below is common.

> This file is the SOURCE for the cadence skills. `build.sh` copies it verbatim into each cadence
> skill folder as `cadence-core.md` (and copies `shared/guidebook.md` into
> `so-best-practice-audit/references/`). Do not edit the copies — edit the `shared/` sources and
> re-run `build.sh`.

## Core Principles

*Canonical: Guidebook §1 (Operating Principles). The below is the operational restatement the
cadence runs from; the data-gate and prefer-native bullets add cadence-specific mechanics not in the
guidebook.*

- **Restricted data gates the whole plan.** If restricted data is involved (as defined for this
  project — Guidebook §1.1), external-model review is not appropriate. Current policy is **warn +
  require explicit acknowledgement**, and the choice is always recorded so it is auditable later.
- **Adapt, don't assume.** Every repo predates this framework. Interview for each app's own
  test runner, deploy command, and validation surface. Never hardcode another app's toolchain.
- **Encourage the baseline, don't require it.** Surface missing best-practice building blocks
  as recommendations, not blockers. The goal is to raise the baseline over time.
- **One decision point per stop.** Do not chain past a mandatory stop without user approval.
- **Track phases visibly.** Multi-gate cycles (especially bug fixes with several review round-trips)
  are easy to get lost in. Maintain a **Phase & Gate Tracker** at the top of the decision log (see
  template) and restate the current phase in each status update, so the user always knows where
  the work is and what gate is next.
- **Surface user-visible behavior changes explicitly.** A change may alter observable semantics
  beyond the stated goal (e.g. a report's "yesterday" switching from latest-active-day to a fixed
  calendar day). List these as a distinct item and get explicit sign-off before rollout — they are
  the ones that surprise users.
- **Prefer native capability over custom logic.** Before hand-rolling a check or workflow step,
  look for an existing platform feature or native skill that already does it — search the platform
  docs, the native skill catalog, **and the organization's own repos for prior art** — and compose
  it. Reinvent only when nothing native fits, and when you do build custom, say explicitly what
  search you ran and why nothing fit. The classification corroboration below is an example: it
  composes the platform's native data classification rather than building custom detection.
- **Fix your own tooling, not the dependency.** When an upstream tool or platform has a bug, the
  fix belongs in your wrapper or your workaround — do not build elaborate machinery inside someone
  else's system. If the user pushes back on an approach twice, re-read the original ask rather than
  escalating the current one.
- **Conform to internal architecture standards during discovery.** Before scoping monitoring,
  alerting, reactive-pipeline, or telemetry-consumption work, surface the **event-driven
  architecture standard** the guidebook prefers (*Canonical: Guidebook §7.3*) and steer the design
  to it: reactive work is **event-triggered**, **never polled** (no tight-schedule change detection,
  no per-entity alert sprawl); consume telemetry through **stable curated views**, not raw internal
  tables (*Canonical: Guidebook §5.4*). The platform's concrete event-trigger mechanism lives in the
  guidebook's §17 appendix. This is a discovery **nudge** — flag any polling / raw-table design as a
  gap; it does not override the interview or the data gate.

## Review-Track Classification (mandatory, before any planning)

*Canonical: Guidebook §1.1 & §2.2. The operational wording below is what the cadence skills ask
verbatim — keep it aligned with the guidebook.*

Ask the restricted-data question explicitly: *"Does this work read, write, derive from, or display
restricted data, as defined for this project?"* — offer Yes / No / Unsure, and state the project's
categories from `AGENTS.md` (Guidebook §1.1) so the user can answer concretely. **Treat Unsure as
Yes** for safety.

- **If restricted = No:** review track is **Internal + external** (plan and diffs get external
  review).
- **If restricted = Yes/Unsure:** WARN clearly that this restricts review to **internal-only** (no
  external-model review), then **require explicit acknowledgement** to proceed. Record the
  exact wording of the acknowledgement.

**⚠️ MANDATORY STOP:** Do not proceed until the user acknowledges the review track.

### Optional corroboration (native classification)

*Extends Guidebook §2.2 (classification corroboration) with the concrete operational procedure —
cadence-specific, not in the guidebook.*

The self-attestation above is authoritative and always runs. When the change touches **named
datasets**, corroborate that answer against the platform's native data classification —
**read-only**, run during discovery once the touched objects are known. This composes a native
governance capability; it does not reimplement detection. The platform's specific classification
tooling is recorded in the guidebook's §17 appendix.

1. **Read existing results** for each touched dataset using the platform's classification read API.
   Read-only; never trigger an on-demand classification scan from this workflow.
2. **Flag restricted** — any field whose classification maps to one of the project's restricted
   categories (Guidebook §1.1), or that the platform marks as an identifier / quasi-identifier.
3. **If restricted data is found and the user answered No/Unsure:** treat as **Yes**, warn, and
   **re-raise the review-track MANDATORY STOP** (a new decision point) before any planning.
   Corroboration can only strengthen the gate — it never downgrades a "Yes."
4. **If no classification data exists / the feature is unavailable / no read access:** note it,
   proceed on the self-attestation alone, and surface a **one-time recommendation** to enable
   automated classification.

**When classification is enabled later:** this check is built to degrade gracefully, so it needs
**no skill change** to activate — the day the platform turns on classification, corroboration
begins returning results automatically. Record the outcome in the decision log (corroboration
fields).

## Deploy-Target Scoping (early, before planning)

*Canonical: Guidebook §4.1 (Definition of Ready — deploy target/environments) & §2.6 (rollout
inventory). An explicit scoping decision that right-sizes the plan; ask it alongside the
review-track question, before generating the phased plan.*

Ask explicitly: *"Is this change targeting a **PROD rollout** (a shared/live environment other
people use), or staying **LOCAL/DEV-only** (run locally or on a dev deploy, not promoted to
users)?"* — offer **PROD** / **LOCAL/DEV**.

- **PROD track:** the full lifecycle applies — the Prod rollout phase, per-PROD rollback capture,
  live monitoring + stakeholder comms, and the pre-PROD external gate (**G3 / pre-closeout**) are
  all in scope.
- **LOCAL/DEV track:** the plan ends after **Dev observe**, and **Cleanup still runs** (scaffolding
  removal is track-independent). Omit the **PROD-specific** rollout ceremony — the Prod rollout
  phase's live monitoring/comms, the per-PROD rollback items, and the **G3** gate. **G1 (plan)** and
  **G2 (interim)** still apply when the external track is active. **If the LOCAL/DEV target still
  deploys anywhere (e.g. a shared dev env), a lightweight Deploy-Surface Inventory still applies**
  (§2.6 expects one before *any* rollout — see below); only a purely local run has nothing to
  deploy. If scope later grows to PROD, **re-raise this decision as a new stop** and add the omitted
  ceremony + G3 back before promoting.

Record the resolved target in the decision log (Deploy target field). This is a scoping decision
only — it never relaxes the restricted-data / review-track gate.

## The Three External Review Gates (when the external track is active)

Review at: (1) **plan** — before implementation; (2) **interim** — after implementation with
tests passing, before QA/docs/rollout; and (3) **pre-closeout** — after docs cleanup, before
PROD rollout, covering the full delta. **Gate 3 is PROD-track only** — on the **LOCAL/DEV** track
(see Deploy-Target Scoping above) it is skipped, since there is no PROD rollout to gate; G1 and G2
still run. The agent always GENERATES the review prompt (see Handoff format). **Re-review vs
proceed:** applying the reviewer's own prescribed revisions does NOT require another gate — apply
and proceed. Route a fresh review only when a revision introduces new scope/behavior, or the work
surfaces a new edge the reviewer hasn't seen. This avoids round-trip churn while still catching
genuinely new risk. If external review is not active (restricted track), note it and proceed
internal-only. When the external track is active, ask the developer to confirm before invoking
`/so-codex-review` at each gate — do not invoke automatically. On explicit yes, run the gate via the
`/so-codex-review` skill (see **Running the gates** below) rather than manual copy/paste. On no or
no response, fall back to the manual handoff format below.

**Standard handoff format** (every gate): the agent generates a concise, self-contained review
prompt; the reviewer returns (1) a one-line **verdict** (approve / revise), (2) **findings**, and
(3) an **explicit next action** so the agent can revise or proceed without ambiguity. Include
enough context to review cold: the goal, the diff/decisions, and any test results.

### Running the gates via /so-codex-review (when the external track is active)

When the review track is **Internal + external**, ask the developer to confirm before invoking
`/so-codex-review` at each gate — never invoke it automatically. Once confirmed, run each gate by
invoking the **`/so-codex-review`** skill instead of a manual copy/paste handoff. Pass it the
resolved assertion (`restricted` and `review_track`), the artifact for the gate, and the change's
**`risk`** (`Standard` | `High` — from the Phase 2 risk assessment; `High` for security, auth,
migrations, concurrency, data-loss / restricted-adjacent, or destructive changes):

- **G1 (plan)** → mode `plan` (pipe the plan text)
- **G2 (interim)** → mode `diff` (reviews the uncommitted working tree)
- **G3 (pre-closeout)** → mode `delta` (reviews the full branch delta vs the base)

`/so-codex-review` owns the mechanics **and** the boundary: it enforces the data gate
**fail-closed** (restricted = Yes/Unsure, or a missing/ambiguous assertion → refusal, sending
nothing externally — this is a refusal, **not** a manual handoff), detects the CLI, selects the
review model and reasoning effort, **degrades without blocking** if the CLI predates the configured
model, and falls back to the manual handoff ONLY when the track is already cleared but the CLI is
absent. It returns the standard verdict / findings / next-action **plus the model/reasoning it ran
on**, which you capture into the matching G1/G2/G3 tracker row and decision log. If
`/so-codex-review` is not installed, use the manual handoff described above.

## Decision Log / Lineage Artifact

*Canonical template: Guidebook §3.1. The template below is the cadence's working copy (skills fill
it in); keep its field names aligned with §3.1.*

**Purpose:** durable, auditable "why" behind each change — interview answers, data classification,
review track, baseline gaps, and (for bugs) root cause and recurrence guard.

**v1 (now):** markdown directory in the project repo, one file per change:
`docs/decisions/<YYYY-MM-DD>-<app-slug>-<slug>.md`
(create the directory if missing). Prefix bug-fix logs with `bug-`:
`<YYYY-MM-DD>-<app-slug>-bug-<slug>.md`. In-repo by default so the log travels with the code; if
the project prefers a central directory, record that choice once and use it consistently.

**v2 (durable pattern — document, don't build unless asked):** a queryable audit table makes
decisions searchable and tamper-evident. Promote to this once the markdown log proves the schema in
practice.

**Template:**
```markdown
# <Feature | Bug>: <summary>
- Date: <YYYY-MM-DD>   App/repo: <app>   Author: <user>
- Restricted data: <No | Yes | Unsure→treated as Yes>
- Review track: <Internal + external | Internal-only (restricted)>
- Deploy target: <PROD | LOCAL/DEV — LOCAL/DEV omits Prod rollout + G3 (Cleanup still runs)>
- Acknowledgement: <verbatim acknowledgement, or N/A>
- Corroboration: <checked N datasets | not applicable (no named datasets) | unavailable (classification not enabled)>
- Corroboration result: <no restricted categories found | restricted data found in <dataset.field> → gate re-raised>

## Phase & Gate Tracker
Legend: [x] done · [~] in progress · [ ] pending · [OP] operator-run. External gates prefixed G.
Keep this current through every gate — it is the at-a-glance "where are we" for the whole cycle.
Rows MIRROR the generated `## Phased plan` phase titles plus the external gates (G1/G2/G3) — this is
the status view of the SAME phases, not a separate fixed model. Regenerate the rows to match the
plan's actual phase titles; the list below is the typical shape, not a required set.
**On the LOCAL/DEV track (see Deploy-Target Scoping), omit the Prod rollout row and the G3 row**
(mark them `[PROD only]` if kept for reference); Cleanup still runs.
For each external gate (G1/G2/G3), record the **model + reasoning** it ran on in the Evidence column
(e.g. `approve — <model>@high` or `revise — degraded/default`), so the model used is auditable per
gate.

| # | Phase / Gate | State | Evidence / outcome |
|---|--------------|-------|--------------------|
| 1 | Reproduce / discovery (read-only) | [ ] | |
| 2 | Risk + data classification / review-track | [ ] | |
| G1 | Plan review | [ ] | |
| 3 | Failing tests first (bug) / tests-first (feature) | [ ] | |
| 4 | Implement | [ ] | |
| G2 | Interim review | [ ] | |
| 5 | Dev observe | [ ] | |
| 6 | Data correction (if any) | [ ] | |
| G3 | Pre-closeout review | [ ] | |
| 7 | Prod rollout + observe | [ ] | |
| 8 | Cleanup (QA/contract docs) | [ ] | |

## Environments & Toolchain
- Dev: <...>   Prod: <...>
- Tests: <...>   Deploy: <...>   Validation surface: <...>
- Deploy surface: <artifacts → deploy mechanism; note anything needing a MANUAL step>
- Exec identity / object owner: <identity that runs each step; owner for owner-executed objects>

## Baseline scan (encouraged, not required)
- [ ] <gap> — <suggested addition>

## User-visible behavior changes
- <observable change beyond the goal> — <sign-off>

## Rollback plan
- <per risky/DB/PROD step: the reverse action captured BEFORE executing>

## Phased plan
<the skill's phased plan — each phase structured per the Execution Phase Format below>

## Decisions & rationale
- <decision> — <why>
```

## Execution Phase Format

*Canonical: Guidebook §2.4 (Phased Plan). The rules below are the cadence's stricter, executable
form of that standard.*

The `## Phased plan` is the artifact that actually gets executed, so structure it for reliable,
agent-assisted execution: each phase must be a **discrete, self-contained unit** that an agent (or
human) can pick up cold and drive to a **stable checkpoint**. Prose stages that require re-reading
the whole plan to infer scope invite drift and skipped verification.

**Each phase uses this format:**
```markdown
### Phase N: <short title>
**Objective:** one sentence — what this phase achieves.
**Inputs:** what must exist before this phase starts (prior deliverables, approvals, data).
**Scope:** what is IN scope; if ambiguous, what is explicitly OUT.
**Deliverable:** the concrete artifact or state change produced.
**Exit criteria:** observable/runnable proof the phase is complete and the branch is stable.
```

**Rules:**

1. **Stable exit invariant.** No phase may end with the branch in a known-broken state. Relevant
   tests pass at every phase boundary — the only permitted red is the failing-tests-first phase,
   whose deliverable *is* the red test — and exit criteria are demonstrated (a command, a test run,
   an observable result), never merely asserted.
2. **Cold-start scope.** Each phase names its own inputs and scope explicitly, so a fresh agent (or
   human) can execute it from the phase block alone without re-deriving intent from the rest of the
   plan. Anything ambiguous is called OUT of scope rather than left implicit.
3. **One deliverable per phase.** A phase produces one concrete artifact or state change. If it
   needs two unrelated deliverables, it is two phases.
4. **Gates sit between phases, never inside them.** External gates (G1/G2/G3) and mandatory stops
   are placed at phase boundaries, on a stable checkpoint, so a `revise` verdict never lands on a
   half-finished phase.
5. **Rollback captured before risky steps.** Any phase that touches PROD, a database, or another
   irreversible surface records the reverse action in the Rollback plan before executing.
6. **Tracker mirrors the plan.** The Phase & Gate Tracker rows are regenerated from these phase
   titles (plus the gates) whenever the plan changes — the plan is the source, the tracker is the
   status view.
