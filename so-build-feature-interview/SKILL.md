---
name: so-build-feature-interview
description: "Guided workflow for planning and building a new feature with review cadence"
user-invocable: true
---

# Feature Development Cadence

Interview-driven workflow that turns a feature idea into a **reviewed, phased plan** following the
shared review cadence, with an auditable record of the decisions made along the way. It orchestrates
the human/tool cadence — it does **not** implement the feature itself, and it cannot force an
external reviewer to run; it produces a review-ready plan and hands off.

## Setup

**Load `cadence-core.md`** (same folder) first. It defines the shared cadence used here: Core
Principles, the restricted-data gate + review-track classification, the three external review gates,
the handoff format, the decision-log artifact + template, and the field-tested learnings — it is the
**operational profile** of the guidebook (`shared/guidebook.md` is the canonical standard; run
`/so-best-practice-audit` to audit work against it). This SKILL.md only adds the
**feature-specific** interview and phased plan.

## When to Use

Any request to add or scope a new feature/enhancement on an **existing** app. If the app does not
exist yet, this is the wrong skill — scaffold the app first, then return here. For fixing a defect
or regression, use `so-bug-review-interview` instead.

## Workflow

### Step 1: Interview

**Goal:** Capture what is being built and the environment it lives in.

Ask the user (use the question tool, group sensibly):
1. **App / repo** being changed (path or name) and a one-line **feature summary**.
2. **Environments**: dev target and prod target (URLs, databases, or "none yet").
3. **Deploy target** — ask as specified in `cadence-core.md` (**Deploy-Target Scoping**):
   is this a **PROD rollout** or **LOCAL/DEV-only**? This right-sizes the plan (LOCAL/DEV omits
   the Prod rollout stage + the G3 gate).
4. **Toolchain**: how tests run, how it deploys, and where correctness is validated post-deploy
   (smoke script, validation procedure, or "none"). Read these from the repo where you can rather
   than making the user recite them.
5. **Restricted-data screen** — ask exactly as specified in `cadence-core.md` (Review-Track
   Classification), stating the project's categories from its `AGENTS.md`.

**Output:** A filled interview record (kept in context for Step 4).

### Step 2: Risk & Data Classification

Apply the **Review-Track Classification** from `cadence-core.md` and honor its MANDATORY STOP
before any planning. Also set the change's **risk** (`Standard` | `High`) here — it feeds the
external gates' reasoning effort.

### Step 3: Discovery + Baseline Scan (read-only)

**Goal:** Understand the code to be changed and where the repo stands against the baseline.

1. Explore the relevant code paths read-only (use an Explore subagent for anything broad).
2. **Native-capability reconnaissance** — before proposing custom logic, check the platform docs and
   the native skill catalog for existing features/skills that already cover part of this work, and
   prefer composing them (per the "Prefer native capability" principle in `cadence-core.md`). If the
   feature touches named datasets, run the **Optional corroboration** from `cadence-core.md` and
   re-raise the data gate if it contradicts the self-attestation.
3. Run the **baseline best-practice scan** and report gaps as *encouraged, not required*:
   - Automated tests / test runner present?
   - Post-deploy smoke or data-validation surface present?
   - Dev vs prod environment separation?
   - A QA/coverage matrix or equivalent contract doc?
   - A decision-log / plan-history convention?
   - Does CI run the repo's own guards, and are generated artifacts proven fresh (§11.1)?
   For each gap, note a one-line suggested addition. Do not expand scope to fix them unless the user
   opts in — just seed the baseline.
4. **Architecture conformance** — check the change against the project's `AGENTS.md` architecture
   boundaries and the shared-package list (Guidebook §5.3). Report non-conformances alongside the
   baseline gaps. This supplements — not replaces — the deeper `/so-best-practice-audit` pass.

**Output:** Discovery notes + baseline gap list.

### Step 4: Generate Phased Plan + Decision Log

**Goal:** Produce the review-ready plan and persist the audit record.

Build a plan enforcing these stages (skip a stage only if the interview shows it does not apply, and
say why). Structure **every** stage using the **Execution Phase Format** from `cadence-core.md`
(Objective / Inputs / Scope / Deliverable / Exit criteria); each phase must be self-contained and
leave the branch stable at its exit (stable exit invariant).

1. **Discovery (read-only)** — findings from Step 3.
2. **Design + plan review** — plan routed to the reviewer (external gate G1).
3. **Dev impl (tests-first)** — write/adjust tests before or with the code, using the repo's own
   runner from Step 1. Prove each new test works by breaking it (Guidebook §10.3).
3b. **Interim code review** — external gate G2: generate a review prompt covering the implemented
   diff + dev test results, route it, apply feedback, then continue.
4. **Dev observe** — validate in the dev-deployed environment.
5. **Pre-closeout review** — external gate G3: full-delta review before PROD rollout.
6. **Prod rollout + observe** — first build the **Deploy-Surface Inventory & Rollout Safety**
   checklist from `cadence-core.md` (enumerate app vs data-object vs config artifacts + their deploy
   path, ownership/grants, rollback, monitoring/comms); then promote and verify post-deploy via the
   repo's validation surface (deployed build == HEAD + real behavior, not just "deploy succeeded").
7. **Cleanup** — remove scaffolding; update the repo's contract/QA doc if one exists.

**Deploy-target scoping (from Step 1):** stages **5 (Pre-closeout / G3)** and **6 (Prod rollout)**
are **PROD-track only**. For a **LOCAL/DEV** target, end the plan at stage 4 (Dev observe) and still
run stage 7 (Cleanup) — see Deploy-Target Scoping in `cadence-core.md`.

Then **write the decision log** using the template in `cadence-core.md` (Feature header).

**⚠️ MANDATORY STOP:** Present the plan + decision-log path and get approval before handoff.

### Step 5: Handoff

- If the review track includes external review: ask the developer to confirm, then run gate G1 via
  `/so-codex-review` (mode `plan`), passing `restricted`, `review_track`, and `risk`. On no, hand the
  plan over for manual review.
- If internal-only: proceed to execution within the agent per the approved plan.

This skill ends at handoff — implementation is done by the normal agent flow, not here.

## Stopping Points

- ✋ Step 2: after data classification / review-track acknowledgement
- ✋ Step 4: after plan + decision log presented, before handoff

## Output

A review-ready phased plan following the shared cadence, plus a persisted decision-log artifact
recording the interview, data classification, review track, and baseline gaps.
