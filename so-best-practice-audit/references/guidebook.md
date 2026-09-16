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
- Deploy instructions and environment mapping.
- Security/privacy notes, including the project's restricted-data categories (§1.1).
- Data dictionary, semantic model, or catalog link for data projects.
- Decision logs, ADRs, or a link to the central decision-log directory.

---

## 5. Architecture and Abstraction

### 5.1 Boundaries

- Separate domain logic from transport, storage, UI, and platform adapters.
- Keep dependency direction explicit and avoid cycles.
- Access external systems through adapters or shared clients, not scattered direct calls.
- Standardize cross-cutting concerns: auth, query execution, caching, error handling, logging,
  telemetry, and configuration.

### 5.2 DRY, WET, and AHA

DRY means do not duplicate knowledge, policy, and business logic. It is appropriate for:

- Authentication and authorization.
- Data access helpers.
- Logging and telemetry.
- Design tokens and shared UI.
- Security controls.
- Stable business metric definitions.
- Tested prompt templates and skill patterns.

WET is acceptable when the domain is still changing:

- Prototypes.
- Unproven prompts.
- Early UX workflows.
- One-off data remediation scripts.
- Business rules likely to diverge.

Create a shared abstraction only when:

- The duplicated behavior is stable.
- At least three uses exist or are clearly imminent.
- Tests exist.
- Ownership and versioning are clear.
- The abstraction reduces complexity instead of hiding it.

### 5.3 Shared Internal Packages

When the organization maintains shared packages for platform access, auth, design tokens, or UI
components, new projects SHOULD use them rather than reimplementing the same concerns. Record the
canonical package list in `AGENTS.md` so agents and new contributors find it without asking.

Reciprocally: when a project hand-rolls something a shared package already covers, that is a
finding, not a style preference.

### 5.4 Data and Interface Contracts

Production datasets and published interfaces SHOULD define:

- Owner.
- Source system.
- Grain — what one row or one record represents.
- Primary key or uniqueness rule.
- Freshness expectation.
- Retention requirement.
- Sensitive fields and classification.
- Allowed consumers.
- Quality checks.
- Backfill behavior.
- Breaking change policy.
- Operational dashboard or validation query.

Transformation rules that apply regardless of engine:

- Transformations MUST be deterministic unless nondeterminism is explicitly required.
- Use explicit column/field lists for production interfaces; avoid `SELECT *` or equivalent
  wildcard projection in stable published interfaces.
- Avoid hidden ordering assumptions.
- Every incremental model MUST define deduplication and late-arriving-data behavior.
- Windowed logic MUST anchor on fixed calendar/clock boundaries when the business definition is
  calendar-based. Do not infer "recent" solely from the newest available data row.

Consume telemetry and shared datasets through **stable curated views or documented interfaces**, not
raw internal tables. This gives consumers a contract and isolates them from schema churn.

---

## 6. Idempotency and Resilience

### 6.1 Idempotency

Any retryable operation MUST be safe to retry or explicitly documented as not retryable.

Patterns:

- API calls use idempotency keys.
- Database writes use unique keys, upserts, transactional merges, or batch IDs.
- Pipelines use watermarks and checkpoints.
- Notifications record send history.
- Migrations record applied versions.
- Agent work happens on branches/worktrees and requires explicit human merge.

### 6.2 Retry Taxonomy

| Error type | Retry? | Pattern |
|---|---|---|
| Validation error | No | Fail fast with actionable error. |
| Auth/authz error | No | Fail closed; alert if unexpected. |
| Not found | Sometimes | Retry only if eventual consistency is expected. |
| Rate limit | Yes | Exponential backoff with jitter. |
| Network timeout | Yes | Bounded retry with idempotency key. |
| Deadlock/lock timeout | Yes | Bounded retry; monitor frequency. |
| Data quality failure | No automatic publish | Quarantine and alert. |
| Unknown exception | Limited | Retry only if the operation is idempotent. |

### 6.3 Fail Safely

- Security failures MUST fail closed.
- Data quality failures MUST prevent material bad data from publishing.
- User-facing applications SHOULD degrade gracefully instead of showing misleading results.
- Agents MUST stop or ask for review when a task exceeds authorized scope.

---

## 7. Observability and Operations

### 7.1 Required Telemetry Fields

Production workflows SHOULD emit:

- `request_id` or `correlation_id`.
- `run_id` or `batch_id`.
- Environment.
- Version or commit SHA.
- Actor or service account.
- Start and end time.
- Status.
- Input count and output count.
- Failure count and error category.
- Retry count.
- Compute and cost indicators where available.

### 7.2 Logging

Logs MUST be:

- Structured where possible.
- Redacted for secrets and restricted data.
- Queryable by correlation ID.
- Actionable for operations.
- Retained according to policy.

Logs MUST NOT include passwords, API keys, tokens, private keys, unmasked restricted data, or
unnecessary raw LLM prompt/output payloads.

### 7.3 Dashboards and Alerts

Dashboards SHOULD answer:

- Is it running?
- Is it correct?
- Is it fresh?
- Is it fast enough?
- Is it within cost expectations?
- What changed recently?
- Who owns it?
- What should operations do next?

Alerts MUST be actionable and routed to an owner.

**Prefer event-driven monitoring over polling.** Reactive work — pipeline monitoring, alerting,
downstream reactions to new data — SHOULD be triggered by a change event rather than a tight polling
loop. Polling burns compute on empty executions and can miss fast transitions. Scheduled jobs are
for work that genuinely runs on a calendar.

- SHOULD NOT run a job on a tight schedule purely to detect changes.
- SHOULD NOT create per-entity alert objects that poll a shared table. Prefer one handler with a
  filter; add an entity by editing the filter, not by adding infrastructure.
- Record the platform's concrete event-trigger mechanism in the §17 appendix so this rule is
  actionable rather than aspirational.

### 7.4 Data Quality

Production datasets SHOULD have checks proportional to business impact:

- Row count and freshness.
- Required-field null checks.
- Duplicate checks.
- Accepted values.
- Referential integrity.
- Future timestamp checks.
- Distribution/anomaly checks.
- Source-to-target reconciliation.

Material quality failures SHOULD write evidence to an operational table and alert an owner.

---

## 8. LLM and Agent Standards

### 8.1 Allowed Uses

LLMs MAY be used for classification, extraction, summarization, translation, documentation drafting,
code review assistance, query generation with guardrails, semantic Q&A over governed data, and
agentic task execution in controlled environments.

LLMs MUST NOT be used as unreviewed final authority for:

- Security-sensitive access decisions.
- Clinical, legal, financial, or compliance determinations.
- Destructive production operations.
- Unverified data modification.
- Silent policy exceptions.

### 8.2 Prompt and Skill Contracts

Production prompts and reusable skills SHOULD define:

- Purpose and owner.
- Trigger conditions and non-goals.
- Input and output schema.
- Safety rules and refusal conditions.
- Model/function target when relevant.
- Evaluation set or review method.
- Changelog.

Skill descriptions SHOULD be short, action-oriented, and placed in YAML frontmatter. Update the
README table and installation script when adding or renaming shared skills.

New or refactored skills MUST be authored via the native `skill-development` skill
(`$skill-development`) before hand-writing a `SKILL.md`; it is the canonical authoring gate. Before
authoring any skill, confirm the need is not already met by a native skill or an existing shared
skill (see §1.2).

### 8.3 Structured Outputs

LLM outputs used by systems SHOULD be structured and validated:

- JSON schema or equivalent.
- Strict field names.
- Allowed categorical values.
- Refusal/error format.
- No downstream execution of unvalidated free text.

### 8.4 LLM Evaluation

Before production use, LLM workflows SHOULD have:

- Golden examples.
- Edge cases.
- Prompt-injection/adversarial cases.
- Regression tests for prompt or model changes.
- Schema validation.
- Human review sampling.
- Accuracy and failure thresholds.
- Drift monitoring.

### 8.5 Agent Autonomy Levels

| Level | Description | Production use |
|---|---|---|
| 0 | Suggest only | Safe default. |
| 1 | Draft artifacts | Allowed with human review. |
| 2 | Modify non-production files | Allowed with tests and review. |
| 3 | Open PRs or change requests | Allowed with human approval before merge. |
| 4 | Execute production changes | Requires scoped permissions, audit, rollback, and explicit approval. |
| 5 | Autonomous production operation | Generally prohibited unless approved for a narrow, low-risk workflow. |

### 8.6 Agent Repository Instructions

Every repo that expects agent help SHOULD include `AGENTS.md`:

```markdown
# AGENTS.md

## Project Overview

## Architecture Boundaries

## Directory Map

## Setup

## Required Checks

## Coding Standards

## Testing Standards

## Security and Privacy Rules
- Restricted-data categories for this project (Guidebook §1.1):

## Data Rules

## UX Rules

## Files Requiring Extra Care

## PR Response Format
- Summary
- Tests run
- Risks/limitations
- Files changed
```

---

## 9. Security and Privacy

### 9.1 Secure Defaults

- Use least privilege.
- Deny by default.
- Validate untrusted input.
- Use parameterized queries.
- Protect secrets.
- Encrypt restricted data in transit and at rest according to policy.
- Maintain dependency inventory and patch vulnerable dependencies.
- Log security-relevant events without exposing secrets.
- Separate ownership identities from consumption identities; use service identities for pipelines
  and services.
- Tag restricted data and apply masking or row-level controls where the platform supports them.
- Verify object ownership and grants after any recreate operation, and verify with a **real
  invocation** using the intended executing identity — not only a compile or deploy check.

The project's **restricted-data categories** (§1.1) are the input to every rule above. Define them
once in `AGENTS.md` and reference them; do not restate them per workflow.

### 9.2 Secrets

Secrets MUST NOT appear in:

- Git history.
- Logs.
- Test snapshots.
- Prompt examples.
- Notebooks.
- Tickets.
- Documentation screenshots.
- Error messages.
- Generated or committed config files. Gitignoring a source config is not sufficient if a generator
  bakes the value into committed output.

If a secret is exposed, rotate it and treat the repository/history as compromised until proven
otherwise.

### 9.3 Threat Modeling

Threat model changes involving:

- New external integrations.
- New auth/authz behavior.
- New restricted-data flow.
- LLM/tool access to internal data.
- Public-facing endpoints.
- Privileged automation.
- Data export.
- Production write capability.

Threat model output SHOULD include assets, actors, trust boundaries, abuse cases, controls, residual
risks, and tests.

### 9.4 AI-Specific Security

LLM/agent workflows MUST consider:

- Prompt injection.
- Data exfiltration through tool calls.
- Overbroad tool permissions.
- Insecure generated code or queries.
- Hallucinated procedures or policies.
- Restricted-data leakage in prompts, outputs, logs, and evals.
- Over-trust in confident but unsupported outputs.

Controls SHOULD include tool allowlists, scoped credentials, output validation, permission-aware
retrieval, human approval for destructive actions, and audit logs.

---

## 10. Testing and QA

### 10.1 Risk-Based Test Mix

Use the lowest-cost reliable test for the risk:

| Test type | Purpose |
|---|---|
| Unit | Verify small logic in isolation. |
| Component | Verify module behavior with controlled dependencies. |
| Integration | Verify real boundaries such as database/API/tool calls. |
| Contract | Verify producer/consumer schema and behavior. |
| End-to-end | Verify critical user journeys. |
| Data quality | Verify accuracy, freshness, uniqueness, completeness, validity. |
| Security | Verify access control, input handling, dependency risk. |
| Accessibility | Verify keyboard and assistive technology behavior. |
| Performance | Verify latency, throughput, cost, and scaling assumptions. |
| LLM eval | Verify prompt/model behavior against expected outcomes. |

### 10.2 Required Test Considerations

Tests SHOULD cover:

- Happy path.
- Boundary values.
- Null/empty input.
- Invalid input.
- Permission failures.
- Dependency failures.
- Retry behavior.
- Duplicate input.
- Out-of-order input.
- Backfill/reprocessing.
- Migration/rollback.
- Observability evidence.

Bug fixes SHOULD include a regression test that fails before the fix and passes after the fix.
Capture the failing evidence in the decision log when practical.

### 10.3 Tests Must Assert Runnable Behavior

A test that greps for a string can pass on a comment while no working code exists. Assert the real
artifact: an executable branch, a parsed structure, an actual invocation — not a substring that
prose could satisfy.

**Prove a new test works by breaking it.** A test that has never failed has not been shown to test
anything. Temporarily remove the fix, confirm the test goes red, restore the fix.

**Run the thing before declaring it done.** A passing suite is not evidence that the workflow works
end to end. Execute the actual command, script, or interaction.

### 10.4 QA Evidence Package

For material releases, QA evidence SHOULD include:

- Test plan and results.
- Known defects.
- Risk acceptance.
- Screenshots or recordings for UX-critical flows.
- Data reconciliation outputs for data changes.
- Security review notes where applicable.
- Approval record.

---

## 11. CI/CD and Release Management

### 11.1 CI Minimum Gates

CI SHOULD run:

- Formatting check.
- Lint/static analysis.
- Type checks where applicable.
- Unit tests.
- Integration tests for changed boundaries.
- Security/dependency scans.
- Query or schema validation where applicable.
- LLM prompt/eval tests when prompt behavior changes.
- Documentation checks for required files.
- **Generated-artifact freshness** — if the repo generates committed files, CI MUST prove the
  committed copies match a fresh run of the generator.

**Enforce in CI what you would otherwise write down as "remember to."** A documented manual step is
a known drift hazard; a CI check is a guarantee. Prefer deriving lists from the filesystem over
maintaining parallel hand-written registries.

Run the repo's own checks locally before pushing.

### 11.2 Deployment Standards

- Deployments MUST be repeatable.
- Infrastructure and database changes SHOULD be scripted.
- Manual steps MUST be documented and minimized.
- Production deploys MUST have rollback or remediation notes.
- Feature flags SHOULD be used for risky changes when feasible.
- Post-deploy verification MUST prove the deployed system changed as intended.

### 11.3 Database Migration Standards

Migrations SHOULD be:

- Versioned.
- Ordered.
- Repeat-safe.
- Tested in lower environments.
- Backward-compatible where possible.
- Paired with rollback or forward-fix strategy.
- Audited after execution.

Avoid destructive migrations without backup/clone strategy, consumer impact analysis, approval,
communication plan, and recovery plan.

---

## 12. Error Handling

### 12.1 Error Categories

Standardize errors into categories:

- Validation.
- Authentication.
- Authorization.
- Not found.
- Conflict.
- Rate limited.
- Dependency failure.
- Timeout.
- Data quality failure.
- Internal error.

### 12.2 User-Facing Errors

User-facing errors SHOULD:

- Explain what happened.
- Explain what the user can do next.
- Avoid exposing internals.
- Preserve user input.
- Provide a correlation ID for support.
- Avoid blame language.

### 12.3 Internal Errors

Internal errors SHOULD include:

- Correlation ID.
- Error category.
- Component.
- Operation.
- Relevant non-sensitive context.
- Stack trace where appropriate and protected.
- Retryability.

---

## 13. Code Review Standards

Reviewers SHOULD evaluate:

- Correctness and stated intent vs actual diff.
- Simplicity and maintainability.
- Test coverage and validation evidence.
- Restricted-data, privacy, and security posture.
- Idempotency and retry safety.
- Error handling and observability.
- Data quality and semantic definitions.
- Performance and compute cost.
- UX and accessibility.
- Backward compatibility.
- Rollback/remediation.
- Documentation and runbook updates.

### 13.1 Pull Request Template

```markdown
## Summary
What changed and why?

## Scope
- [ ] Application code
- [ ] Database/data platform
- [ ] Infrastructure
- [ ] UX
- [ ] LLM/prompt/agent behavior
- [ ] Documentation

## Data Classification / Privacy
- Restricted data: <No | Yes | Unsure treated as Yes>
- Review track: <Internal + external | Internal-only>
- Decision log:

## User-Visible Behavior Changes
- <none | list approved changes>

## Validation
- [ ] Unit tests
- [ ] Integration tests
- [ ] Data quality checks
- [ ] Security checks
- [ ] Accessibility checks
- [ ] LLM evals
- [ ] Manual QA

## Deploy Surface
- App/service:
- Data objects:
- Config/env:
- Manual steps:
- Execution identity / owner:

## Operational Impact
- [ ] Logs/metrics updated
- [ ] Dashboard/alert updated
- [ ] Runbook updated
- [ ] Rollback/remediation documented

## Notes for Reviewer
Known tradeoffs, limitations, or follow-up work.
```

---

## 14. Templates

### 14.1 ADR Template

```markdown
# ADR: <Decision title>

## Status
Proposed | Accepted | Deprecated | Superseded

## Date
YYYY-MM-DD

## Context
What problem are we solving? What constraints matter?

## Decision
What did we decide?

## Alternatives Considered
1. Option A
2. Option B
3. Option C

## Consequences
Positive, negative, operational, security, cost, maintenance.

## Validation
How will we know the decision worked?

## Review Date
YYYY-MM-DD
```

### 14.2 Data Contract Template

```markdown
# Data Contract: <Dataset name>

## Owner

## Purpose

## Source Systems

## Grain
One row represents...

## Primary Key / Uniqueness Rule

## Freshness Expectation

## Retention

## Sensitive Fields

## Tags / Classification

## Schema
| Column | Type | Required | Description | Quality rule |
|---|---|---:|---|---|

## Quality Checks

## Consumers

## Breaking Change Policy

## Backfill / Reprocessing Behavior

## Operational Dashboard or Query
```

### 14.3 Runbook Template

```markdown
# Runbook: <System/workflow>

## Owner

## Purpose

## Architecture Summary

## Dependencies

## Normal Schedule / Trigger

## Dashboard / Operational Queries

## Alert Conditions

## Common Failure Modes
| Symptom | Likely cause | Action | Escalation |
|---|---|---|---|

## Retry Procedure

## Rollback / Remediation

## Data Reconciliation

## Communication Plan

## Last Reviewed
YYYY-MM-DD
```

### 14.4 Prompt Card Template

```markdown
# Prompt Card: <Prompt name>

## Owner

## Use Case

## Model / Function Target

## Autonomy Level
0 | 1 | 2 | 3 | 4 | 5

## Input Schema

## Output Schema

## Prompt Version

## Prompt Text

## Examples

## Refusal / Safety Rules

## Evaluation Dataset

## Metrics

## Known Limitations

## Monitoring

## Changelog
```

---

## 15. Compliance Rubric

Use this scoring model in project reviews.

| Area | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Requirements | Undefined | Partial | Clear | Clear, testable, traceable |
| Data classification / privacy | Not classified | Informal | Classified and recorded | Corroborated, auditable, enforced |
| Architecture | Ad hoc | Some boundaries | Documented | Documented with ADRs and failure modes |
| Idempotency | Unsafe | Partial | Mostly retry-safe | Retry-safe with evidence |
| Testing | Manual only | Basic automated | Good coverage | Risk-based, automated, traceable |
| Observability | Minimal | Logs only | Logs plus metrics | Logs, metrics, dashboards, alerts |
| Security | Not reviewed | Basic review | Controls applied | Threat modeled and verified |
| Data quality | None | Ad hoc checks | Standard checks | Automated checks with alerts and evidence |
| UX | Developer-centric | Basic usable | User-tested | Accessible, observable, error-resilient |
| LLM/agent control | Uncontrolled | Manual review | Versioned prompts/tools | Evaluated, monitored, permissioned |
| CI enforcement | None | Manual checklist | CI runs tests | CI enforces generated artifacts and registries |
| Maintainability | High burden | Some docs | Clear docs | Low operational burden, clear ownership |

Production readiness target: no category below 2. High-risk systems should target 3 in data
classification/privacy, security, observability, idempotency, and testing.

---

## 16. Review Cadence

Review this guide:

- Quarterly.
- After major incidents.
- After material platform changes.
- After adopting new agent capabilities.
- After audit findings.
- When repeated review comments reveal a missing standard.

Each review SHOULD produce:

- Added standards.
- Removed obsolete standards.
- Clarified ambiguous standards.
- Updated templates.
- Updated enforcement checks.

---

## 17. Platform Standards (project-defined, external to this file)

This guide is stack-agnostic by design, and **this file is never edited by an adopting project** —
that is what keeps it upgradable. Concrete platform rules live in a separate, project-owned
document:

```
shared/platform.md          <- yours; no two projects share it
shared/platform.example.md  <- the template it is copied from
```

Run `/so-init` to be interviewed and have it written, or copy the template and fill it in by hand.

**Seven sections, in `platform.md`:** environment separation · event-trigger mechanism · deploy
commands (and what each does *not* cover) · data classification tooling · shared internal packages ·
reference implementations · project-specific additions.

**Rules in this guide that stay principles until `platform.md` answers them:**

| Guidebook rule | Needs |
|---|---|
| §2.2 classification corroboration | Data classification tooling |
| §5.3 use shared packages | Shared internal packages |
| §7.3 event-triggered, not polled | Event-trigger mechanism |
| §11.2 post-deploy verification | Deploy commands |

An absent or empty `platform.md` is reported as a finding by `so-best-practice-audit` rather than
silently passing. The system fails honestly instead of inventing platform mechanics it cannot know.

### 17.1 Source Anchors to Verify Periodically

Verify current vendor and standards documentation for:

- The platform's data classification, masking, and access-control features.
- The platform's scheduling, event, and pipeline primitives.
- The platform's deploy tooling and CLI behavior.
- Agent/skill authoring and installation behavior for the agent runtime in use.
- The external review CLI and its `AGENTS.md` conventions.
- NIST Secure Software Development Framework.
- OWASP ASVS and OWASP Top 10.
