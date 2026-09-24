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
  Use only the current project's documented or user-supplied infrastructure context; do not carry
  server names, endpoints, accounts, or paths over from unrelated projects or prior sessions.
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
  docs, the native skill catalog, and reference implementations documented by the current project
  when available — and compose it. Reinvent only when nothing native fits, and when you do build
  custom, say explicitly what search you ran and why nothing fit. Classification corroboration, for
  example, composes native data classification rather than building custom detection.
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

*Canonical: Guidebook §2.5.* Keep handoffs portable: replace private server names, internal URLs,
IP addresses, account identifiers, and personal filesystem paths with consistent placeholders
such as `<dev-host>`, `<prod-host>`, `<repo-url>`, and `<project-root>`. Apply this to command
examples, logs, and test output as well as prose. Omit any mapping back to private values; do not
fill gaps with infrastructure remembered from another project or session. This applies to manual
and automated handoffs and does not clear a restricted review track.

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
   tests/checks pass at phase exit and existing functionality remains intact — no phase relies on
   the *next* phase to restore stability.
2. **Red-test exception is transient only.** A bug fix may need to prove a regression test fails
   *before* the fix. That red state must be captured and resolved *inside* one phase (show it fails
   → apply the fix → it passes). A phase may go red mid-way, but **no phase may END red**.
3. **Coarse, not tiny.** A phase is one focused work session with a clear checkpoint (e.g. "implement
   feature + tests"), not a single line edit. Typical plans stay ~7–9 phases. The goal is stability
   at each checkpoint, not maximal fragmentation.
4. **Executable exit criteria.** "Verify it works" is not enough. Use concrete
   commands/observations: the repo's test command → 0 failures; load the page and confirm the new
   filter renders. Reference the Deploy-Surface Inventory and field-tested learnings from the
   rollout phase's exit criteria rather than duplicating them (e.g. "deployed build == HEAD and real
   behavior verified").
5. **Tracker alignment.** The Phase & Gate Tracker (above) mirrors these generated phase titles plus
   the external gates (G1/G2/G3) — it is the at-a-glance status view of the SAME phases, not a
   competing fixed phase model. Keep tracker rows and generated phase titles in sync.

**Well-formed example:**
```markdown
### Phase 3: Implement with tests-first
**Objective:** Implement the feature with regression coverage using the repo's test runner.
**Inputs:** Approved plan from Gate 1; discovery notes from Phase 1.
**Scope:** Tests + implementation on the working branch. Excludes deploy/env validation (Phase 5).
**Deliverable:** Feature code + tests; all tests passing locally.
**Exit criteria:** the repo's test command exits 0; new tests cover the plan's acceptance criteria; no pre-existing tests skipped or weakened.
```

**Anti-pattern:** `3. Dev impl — write the code and some tests.` (no scope boundary, no inputs, and
"some tests" is not an observable exit criterion — an agent cannot tell when this is done or stable).

## Deploy-Surface Inventory & Rollout Safety

*Canonical: Guidebook §2.6 (Rollout Inventory). Operational checklist below.*

Before any PROD rollout, enumerate what actually ships and how — the "rollout" stage is where
silent, half-deployed changes hide.

> **Scales with the deploy.** The full ceremony below (execution-identity/ownership checks,
> per-step rollback, live monitoring + stakeholder comms) gates a **PROD rollout**. A **LOCAL/DEV**
> target that still deploys to a shared dev env keeps a **lightweight** inventory (changed artifacts
> + deploy mechanism + any manual step); a purely local run (no deploy) has nothing to inventory.
> Per Guidebook §2.6, do an inventory before *any* rollout — scale its depth to the target.

- **Deploy-surface inventory.** List every changed artifact and its deploy mechanism: app bundle,
  DB objects (procedures / tables / jobs / views), config/env, scheduled work. Different surfaces
  deploy via different commands — e.g. an app-deploy command may NOT apply schema DDL. Anything not
  covered by an automated deploy needs an explicit MANUAL step in the runbook.
- **Execution identity + ownership.** State which identity runs each step and whether it has the
  privileges. For DB objects: recreate operations reset ownership; owner-executed objects need the
  OWNER (not the caller's secondary roles) to hold the required grants. Restore ownership + regrant
  after every recreate, and VERIFY with a real invocation — a lightweight check can pass while the
  full path fails on an ownership/authorization gap.
- **Verify deployed build == source and behavior.** Confirm the deployed version/commit equals the
  intended HEAD and that real behavior changed — not just "deploy succeeded." Prefer running deploys
  in the foreground; backgrounded deploys can ship stale build metadata.
- **Rollback plan per risky step.** For each DB-object or PROD step, capture the reverse action
  (saved prior definition / inverse command) BEFORE executing, so a failure is recoverable.
- **Monitor + notify for live/multi-tenant targets.** If the target is actively used by others, add
  a post-deploy monitoring window and a stakeholder heads-up to the rollout/closeout stage.
- **Post-merge hygiene.** Once merged, delete the merged feature branch (local `git branch -d` +
  remote delete) unless the MR's "delete source branch" option already removed it. Keeps stale
  branches from accumulating.

## Field-Tested Learnings (verify, don't assume)

Hard-won from real cycles — apply during Dev observe / Prod rollout:

- **Verify deployed *behavior*, not "deploy succeeded."** Build/version endpoints and deploy
  logs can report stale or misleading state. Confirm the change by observing real behavior on
  the deployed env — a data value, a sort order, a rendered style — not the exit code.
- **Run the app locally and inspect computed output before any deploy.** A CSS-specificity or
  logic bug can pass typecheck + tests + build yet render wrong. Check the actual DOM/values.
- **Run it before declaring it done.** A detailed spec and a green suite can both pass while the
  workflow is broken end to end. Execute the real command or interaction.
- **Know your smoke's auth model.** Strict smoke without a session cookie can fail/skip every
  auth-gated check — a false negative. Verify via authenticated checks instead.
- **DB object redeploys drop grants.** Recreating a procedure or view drops non-owner grants; the
  scheduled executor identity then hits "unknown object" and the job auto-suspends. After any
  redeploy, regrant and re-verify with the *actual* executor identity.
- **Some failures only appear in prod-like data.** A metric can pass in one env and fail
  transiently in another (timing/volume). Trigger the dependent job and re-check before
  treating it as a defect.
- **Keep the decision log current through every gate** — verdicts, revisions, deploy results,
  and surprises. It is the audit trail.
- **Guard tests must assert *runnable* artifacts, not string presence.** A test that greps for a
  name can pass on a comment ("PROD block is identical…") while no runnable code exists. Assert the
  real thing: an actual executable clause, N distinct blocks, a real branch — not a substring a
  comment could satisfy.
- **Prove a new test works by breaking it.** Remove the fix, confirm the test goes red, restore the
  fix. A test that has never failed has not been shown to test anything.
- **When a fix changes an artifact's *shape*, update sibling regression tests to preserve the
  original invariant, not weaken it.** Switch an exact-string assertion to a pattern that still
  proves the invariant, then re-confirm the guard still fails without the fix.
- **Verify data repairs with before/after reconciliation over a window ≥ the correction window.**
  Capture the gap set before, apply the repair, confirm zero after. Classify residual gaps as
  *persistent* (older than the correction window → real recurrence / repair failed) vs
  *transient* (within it → self-heals next cycle) so the recurrence check is low-noise.
- **Check project guidance before improvising infrastructure fixes.** Consult the current project's
  runbook and documented reference implementations for network, proxy, and certificate setup.
  Do not assume access to other repositories or reuse another environment's configuration.
