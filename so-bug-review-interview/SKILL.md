---
name: so-bug-review-interview
description: "Guided workflow for diagnosing and fixing bugs with review cadence"
user-invocable: true
---

# Bug Review Cadence

Interview-driven workflow that turns a bug report into a **reproduced, root-caused, reviewed, phased
fix plan** with an auditable decision log. It is deliberately backward-looking: prove the cause and
guarantee non-recurrence before proposing a fix. It orchestrates the human/tool cadence — it does
**not** apply the fix itself, and it cannot force an external reviewer to run; it produces a
review-ready plan and hands off.

## Setup

**Load `cadence-core.md`** (same folder) first. It defines the shared cadence used here: Core
Principles, the restricted-data gate + review-track classification, the three external review gates,
the handoff format, the decision-log artifact + template, and the field-tested learnings — it is the
**operational profile** of the guidebook (`shared/guidebook.md` is the canonical standard; run
`/so-best-practice-audit` to audit work against it). This SKILL.md only adds the **bug-specific**
interview and investigation loop.

## When to Use

Any report of incorrect, broken, regressed, or silently-wrong behavior in an **existing** app.
For adding new capability, use `so-build-feature-interview` instead. The dividing line: a bug has
an *expected vs actual* gap; a feature does not yet exist.

## Workflow

### Step 1: Interview

**Goal:** Capture the symptom and the environment precisely enough to reproduce it.

Ask the user (use the question tool, group sensibly):
1. **App / repo** and a one-line **symptom summary**.
2. **Expected vs actual** — what should happen, what actually happens.
3. **Regression window** — when did it last work / when was it first noticed? Any recent
   deploy, data change, or dependency bump near that boundary?
4. **Severity & exposure** — who/what is affected, and could it be **silently corrupting data
   or misleading users** (as opposed to a visible error)? Silent-wrong is highest priority.
5. **Toolchain:** how tests run, how it deploys, where correctness is validated post-deploy.
6. **Deploy target** — ask as specified in `cadence-core.md` (**Deploy-Target Scoping**): is the
   fix headed for a **PROD rollout** or **LOCAL/DEV-only**? This right-sizes the plan (LOCAL/DEV
   omits the Prod rollout stage + the G3 gate).
7. **Restricted-data screen** — ask exactly as specified in `cadence-core.md` (Review-Track
   Classification), stating the project's categories from its `AGENTS.md`.

**Output:** A filled bug interview record (kept in context for Step 5).

### Step 2: Risk & Data Classification

Apply the **Review-Track Classification** from `cadence-core.md` and honor its MANDATORY STOP
before any fix planning. Also set the change's **risk** (`Standard` | `High`) here — it feeds the
external gates' reasoning effort. Data-loss and security bugs are `High`.

### Step 3: Reproduce First (read-only)

**Goal:** Establish a concrete, observable reproduction before theorizing about causes.

1. Reproduce the symptom against real data / the dev env — capture the exact failing input,
   query, or interaction and the wrong output.
2. If it cannot be reproduced, do NOT guess a fix. Record why (flaky, data-dependent,
   environment-specific) and propose how to make it observable (logging, a targeted query, a
   narrower dataset) before proceeding.

**⚠️ MANDATORY STOP:** Do not proceed to root-cause until the bug is reproduced, OR the user
explicitly accepts proceeding on an unreproduced bug with the recorded rationale.

### Step 4: Root Cause + Blast Radius (read-only)

**Goal:** Locate the *cause*, not just where the symptom surfaces, and find every sibling.

1. **Root cause vs symptom** — trace to the line/logic that produces the wrong result. Name
   the cause location explicitly; distinguish it from where the user *notices* it.
2. **Blast-radius scan** — grep/Explore for the same defect pattern elsewhere (the same query
   shape, the same off-by-one window, the same missing guard). A fix that leaves siblings
   unfixed is incomplete. List every occurrence found.
3. **Corruption assessment** — did the bug already write bad data or mislead users/decisions?
   If so, note whether a backfill / correction / user-notice is needed (this becomes a plan
   stage, not an afterthought).
4. **Native-capability reconnaissance** — before proposing custom logic, check the platform docs and
   the native skill catalog for existing features/skills that already cover part of the fix, and
   prefer composing them (per the "Prefer native capability" principle in `cadence-core.md`). The
   touched datasets/queries are known by now, so run the **Optional corroboration** from
   `cadence-core.md` and re-raise the data gate if it contradicts the self-attestation.
5. **Upstream vs ours** — if the root cause is in a dependency or platform, the fix belongs in *our*
   wrapper or workaround, not in elaborate machinery inside the dependency. Say which you chose and
   why.

**Output:** Root-cause location, sibling list, corruption assessment.

### Step 5: Generate Phased Fix Plan + Decision Log

**Goal:** Produce the review-ready fix plan and persist the audit record.

Build a plan enforcing these stages (skip a stage only if the investigation shows it does not
apply, and say why). Structure **every** stage using the **Execution Phase Format** from
`cadence-core.md` (Objective / Inputs / Scope / Deliverable / Exit criteria); each phase must be
self-contained and leave the branch stable at its exit (stable exit invariant).

1. **Reproduce + root cause (read-only)** — findings from Steps 3–4.
2. **Fix design + plan review** — plan routed to the reviewer (external gate G1). Must state the
   cause, the fix, and the sibling occurrences the fix covers.
3. **Failing regression test, then fix (one phase)** — per the **transient red-test rule** in
   `cadence-core.md`, prove and resolve the red state *inside a single phase*:
   - **3a. Prove it red** — add a test that reproduces the bug and **fails before the fix** on the
     repo's own runner. This is the anti-recurrence guarantee; capture the failing output in the log.
   - **3b. Make it green** — apply the fix so the test passes, fixing all siblings from Step 4 in the
     same change.
   Exit criteria: the new test FAILED at 3a (captured in the log) and now PASSES, and the full suite
   is green. This phase does not end red.
- **G2. Interim code review** — external gate G2: review the fix diff + the now-passing test.
4. **Dev observe** — confirm the symptom is gone on the dev-deployed env (verify *behavior*,
   not "deploy succeeded" — see field-tested learnings).
5. **Data correction** (only if Step 4 found corruption) — backfill / re-run dependent jobs /
   notify affected users; verify with the actual executor identity, and reconcile before/after over
   a window ≥ the correction window.
6. **Pre-closeout review** — external gate G3: full-delta review before PROD rollout.
7. **Prod rollout + observe** — first build the **Deploy-Surface Inventory & Rollout Safety**
   checklist from `cadence-core.md` (enumerate app vs data-object vs config artifacts + their deploy
   path, ownership/grants, rollback, monitoring/comms); then promote and verify via the repo's
   validation surface (deployed build == HEAD + real behavior, not just "deploy succeeded").
8. **Cleanup** — remove scaffolding; update the repo's contract/QA doc if one exists.

**Deploy-target scoping (from Step 1):** stages **6 (Pre-closeout / G3)** and **7 (Prod rollout)**
are **PROD-track only**. For a **LOCAL/DEV** target, end the plan at stage 4 (Dev observe) — plus
stage 5 (Data correction) if corruption was found — and still run stage 8 (Cleanup); see
Deploy-Target Scoping in `cadence-core.md`.

Then **write the decision log** using the template in `cadence-core.md`, with a **Bug** header
and the extra fields: `Symptom`, `Root cause`, `Regression window`, `Sibling occurrences`,
`Regression test added`, `Corruption / backfill`.

**⚠️ MANDATORY STOP:** Present the fix plan + decision-log path and get approval before handoff.

### Step 6: Handoff

Use the **Standard handoff format** in `cadence-core.md`, including its placeholders for private
infrastructure and personal paths in the plan and reproduction evidence.

- If the review track includes external review: ask the developer to confirm, then run gate G1 via
  `/so-codex-review` (mode `plan`), passing `restricted`, `review_track`, and `risk`. On no, hand the
  plan over for manual review.
- If internal-only: proceed to execution within the agent per the approved plan.

This skill ends at handoff — the fix is applied by the normal agent flow, not here.

## Bug-specific field-tested learnings

Hard-won from real bug cycles (in addition to the shared learnings in `cadence-core.md`):

- **Anchor windowed bucketing on a fixed calendar/clock boundary, never on data presence.**
  Both "position slicing" (take the newest N active rows) and "anchor on the latest active row"
  silently recreate window-edge bugs for sparse or all-old-data users — old activity gets
  mislabeled as recent. Derive the window from a fixed clock/calendar, then do date-only math.
- **Edge cases ARE part of the blast radius — enumerate and test them.** For any windowed or
  aggregating fix, explicitly cover: sparse data, all-old data, empty, single item, and
  calendar/timezone/DST boundaries. "Tests green" on the happy path is not done; reviewers will
  (rightly) find the sparse/all-old case.
- **Expect iterative review to surface latent edges.** A single fix often masks a second-order
  bug in the same area (e.g. fixing ordinal slicing revealed anchor-on-data). Treat each review
  round's finding as a prompt to re-scan the blast radius, not just patch the one line.
- **A green suite is not a reproduction.** If the tests passed before the fix and after, the test
  does not cover the bug. Go back to Step 3.

## Stopping Points

- ✋ Step 2: after data classification / review-track acknowledgement
- ✋ Step 3: after reproduction (or accepted rationale for an unreproduced bug)
- ✋ Step 5: after fix plan + decision log presented, before handoff

## Output

A review-ready phased fix plan following the shared cadence — grounded in a reproduction, a named
root cause, a blast-radius list, and a failing-first regression test — plus a persisted decision-log
artifact.
