# Software Project Best Practices Guidebook

**Version:** 1.0
**Date:** 2026-09-14
**Audience:** engineers, data scientists, QA, operations, product partners, and workflow/skill maintainers
**Purpose:** define the default operating standard for building resilient, auditable, secure, testable, low-maintenance software and data systems.

This guide is intentionally practical and **stack-agnostic**. It describes the baseline expected of
production-facing work while leaving room for exploratory analysis, prototypes, and one-off
investigation. When a project has a stronger local standard, follow the stronger standard and
document the difference.

> **Project setup:** two things are deliberately not in this file and MUST be defined per project
> before the standard is fully enforceable — the **restricted-data categories** in §1.1/§9.1 (record
> them in `AGENTS.md`) and the **platform standards** in `shared/platform.md` (§17). Run `/so-init`
> to be interviewed for both. Everything else applies as written, unedited.

---

## 0. Normative Language

| Term | Meaning |
|---|---|
| **MUST** | Required for production work unless a time-bound waiver is recorded. |
| **MUST NOT** | Prohibited unless a time-bound waiver is recorded. |
| **SHOULD** | Strong default. Exceptions need a written reason. |
| **MAY** | Optional pattern. |
| **WAIVER** | A documented exception with owner, rationale, risk, mitigation, and expiration. |

Every production repository SHOULD link this guide, or a project-specific derivative, from
`README.md`, `AGENTS.md`, `RUNBOOK.md`, or the project decision log.

---

## 1. Operating Principles

### 1.1 Restricted Data Gates the Plan

- Any work that reads, writes, derives from, or displays **restricted data** MUST be classified
  before planning or external review.
- If the answer is **Yes** or **Unsure**, treat it as restricted. Review stays internal and content
  MUST NOT be sent to an external model-review service.
- If the answer is **No**, the standard review track is internal plus external review, subject to
  sanitization and local policy.
- The review-track decision MUST be recorded in the decision log.

**Define "restricted" per project.** This gate is only meaningful once the project names its
categories. Record them in `AGENTS.md` or a project derivative of this guide. Common categories:

| Category | Examples |
|---|---|
| Personal data | names, addresses, emails, phone numbers, national identifiers, dates of birth |
| Regulated data | health records, payment-card data, financial account data |
| Customer-confidential | customer-owned data held under contract |
| Company-confidential | unreleased plans, security findings, credentials, trade secrets |

A project with no restricted-data exposure records that explicitly. It does not skip the gate.

### 1.2 Correctness Before Cleverness

- Correct behavior includes data accuracy, privacy, security, accessibility, operational safety,
  cost control, and user trust.
- Prefer simple, observable, platform-native patterns over custom machinery.
- Before hand-rolling a workflow, check whether the platform, a shared internal package, or an
  existing skill already covers the need.

### 1.3 Make Work Visible and Auditable

- Material changes SHOULD create a decision log capturing the problem, data classification, review
  track, assumptions, baseline gaps, plan, gates, and rollout evidence.
- Every production workflow SHOULD expose status, owner, inputs, outputs, failures, retry behavior,
  version, and where to look during an incident.
- Hidden manual steps are operational risk. Eliminate them, automate them, or document them in the
  runbook and rollout checklist.

### 1.4 Stable Checkpoints Beat Big Bang Changes

- Work SHOULD be split into phases that end in a stable state.
- A phase may temporarily go red while proving a regression test, but it MUST NOT end red.
- Every phase needs concrete exit criteria: commands, deployed observations, validation queries,
  screenshots, or data reconciliation.

### 1.5 Human Accountability Remains Mandatory

- Agents and LLMs MAY draft code, plans, documentation, tests, queries, summaries, and reviews.
- Agents MUST NOT be the final accountable owner of a production change.
- Human reviewers remain responsible for validating privacy, security, data semantics, business
  behavior, and rollout readiness.

---

## 2. Standard Change Cadence

Use this cadence for material feature work, bug fixes, deployments, schema changes, production data
workflows, and agent-assisted work. Small documentation or exploratory changes may use a lighter
version, but the restricted-data gate still applies.

### 2.1 Intake

Capture:

- App, repo, workflow, or data objects involved.
- One-line summary of the feature, bug, or operational need.
- Expected user/system behavior and non-goals.
- Data sources, downstream consumers, and named datasets if known.
- Environments: local, dev, QA/stage, production.
- Test runner, deploy command, validation surface, and owner.
- Restricted-data classification: No, Yes, or Unsure.
- Acceptance criteria and definition of done.

### 2.2 Review-Track Classification

Ask explicitly:

> Does this work read, write, derive from, or display restricted data, as defined for this project
> (§1.1)?

Rules:

- **No:** review track is internal plus external review.
- **Yes or Unsure:** review track is internal-only. Require explicit acknowledgement before
  proceeding.
- If named datasets are touched, corroborate the answer where the platform offers automated data
  classification.
- Corroboration can only strengthen the gate. It never downgrades a restricted answer.

### 2.3 Discovery and Baseline Scan

Before implementation:

- Read the relevant code, configuration, tests, deploy files, runbooks, and known incidents.
- Identify the repo's real test and deploy commands instead of assuming a toolchain.
- Check for existing platform or internal capabilities before proposing custom logic.
- Record baseline gaps as recommendations, not blockers:
  - Automated tests.
  - Post-deploy smoke or validation check.
  - Dev/prod separation.
  - QA or contract documentation.
  - Decision-log convention.
  - Runbook and owner.
  - Observability and alerting.

### 2.4 Phased Plan

Every material plan SHOULD use discrete phases with this structure:

```markdown
### Phase N: <short title>
**Objective:** One sentence describing what this phase achieves.
**Inputs:** Prior approvals, artifacts, data, or environments required.
**Scope:** What is in scope and, when useful, explicitly out of scope.
**Deliverable:** The concrete artifact or state change produced.
**Exit criteria:** Observable proof the phase is complete and stable.
```

Planning rules:

- Each phase must be self-contained enough for an engineer or agent to pick up cold.
- Each phase must end with the branch, data state, or deployed environment stable.
- Exit criteria must name concrete checks: the repo's test command, its build command, its deploy
  command, validation queries, visual QA, or a real app interaction.
- User-visible behavior changes beyond the stated goal MUST be called out separately and approved.

### 2.5 Review Gates

When the review track includes external review:

- **G1 plan review:** review the plan before implementation.
- **G2 interim review:** review the implemented diff after tests pass and before QA/rollout cleanup.
- **G3 pre-closeout review:** review the full branch delta before production rollout.

When the review track is internal-only:

- Keep the same review discipline internally.
- Do not send restricted content to external review.
- Record that external review was skipped because of the data boundary.

External reviews are advisory data. The caller and human reviewer decide what to apply.

### 2.6 Rollout Inventory

Before any dev or production rollout, enumerate exactly what ships:

- Application bundle, container image, service, or static assets.
- Database and infrastructure objects: procedures, views, tables, jobs, policies, secrets,
  integrations, and grants.
- Config/environment changes.
- Manual steps not covered by the automated deploy.
- Execution identity and object owner for each step.
- Rollback or forward-fix action for every risky step.
- Post-deploy verification proving deployed source equals intended source and behavior changed.

---

## 3. Decision Logs and Lineage

Material work SHOULD create a durable decision log. Store it in the project repo, or in a central
decision-log directory when that is the stronger local convention. Whichever is chosen, record the
location once and use it consistently:

```text
docs/decisions/<YYYY-MM-DD>-<app-slug>-<slug>.md
docs/decisions/<YYYY-MM-DD>-<app-slug>-bug-<slug>.md
```

### 3.1 Decision Log Template

```markdown
# <Feature | Bug | Change>: <summary>
- Date: <YYYY-MM-DD>
- App/repo:
- Author:
- Owner:
- Restricted data: <No | Yes | Unsure treated as Yes>
- Review track: <Internal + external | Internal-only>
- Acknowledgement: <verbatim or N/A>
- Classification corroboration: <checked N datasets | not applicable | unavailable>
- User-visible behavior changes: <none | list with sign-off>

## Phase & Gate Tracker
| # | Phase / Gate | State | Evidence / outcome |
|---|---|---|---|
| 1 | Discovery | [ ] | |
| G1 | Plan review | [ ] | |
| 2 | Implement with tests | [ ] | |
| G2 | Interim review | [ ] | |
| 3 | Dev observe | [ ] | |
| G3 | Pre-closeout review | [ ] | |
| 4 | Prod rollout + observe | [ ] | |
| 5 | Cleanup | [ ] | |

## Environments & Toolchain
- Local/dev:
- QA/stage:
- Production:
- Tests:
- Deploy:
- Validation surface:
- Execution identity / object owner:

## Baseline Scan
- [ ] <gap> - <suggested addition>

## Rollback / Remediation
- <step> -> <reverse action or forward fix>

## Phased Plan
<phase details>

## Decisions & Rationale
- <decision> - <why>
```

### 3.2 Bug-Specific Additions

Bug logs SHOULD also include:

- Symptom.
- Expected vs actual behavior.
- Regression window.
- Root cause location.
- Blast-radius scan and sibling occurrences.
- Regression test added.
- Whether bad data was written or users were misled.
- Backfill, correction, or notification decision.

---

## 4. Project Lifecycle Standards

### 4.1 Definition of Ready

A task is ready when these are known or explicitly deferred:

- Goal and non-goals.
- Expected user or system behavior.
- Inputs, outputs, and contracts.
- Data classification and review track.
- Acceptance criteria.
- Test expectations.
- Failure behavior.
- Logging and operational visibility.
- Deployment target and owner.
- Rollback or remediation path.
- Constraints for agents and automated tools.

Exploratory tasks may proceed with fewer details, but MUST be labeled exploratory and SHOULD NOT
ship directly to production.

### 4.2 Definition of Done

A change is done only when:

- Acceptance criteria are met.
- Data-classification and review-track decisions are recorded.
- Tests and required checks pass or a waiver is documented.
- Security, privacy, and data impacts are reviewed.
- User-visible behavior changes are approved.
- Data contracts and semantic definitions are updated if affected.
- Operational behavior is observable.
- Rollback/remediation is documented.
- No secrets, debug output, temporary code, or untracked manual steps remain.
- Deployment was verified by real behavior, not only by a successful command.

### 4.3 Repositories

Production repositories SHOULD include:

- `README.md` with purpose, setup, architecture overview, and common commands.
- `AGENTS.md` when agents are expected to work in the repo.
- `RUNBOOK.md` for operational workflows.
- Test, lint, typecheck, and build commands.
