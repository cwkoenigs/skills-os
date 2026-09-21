<!-- GENERATED FILE — do not edit. Source: shared/platform.example.md. Run ./build.sh to regenerate. -->

# Platform Standards

<!--
  TEMPLATE — copy to shared/platform.md and fill in, or run /so-init to be interviewed.

  Why this file is separate from the guidebook:
  shared/guidebook.md is the canonical, upgradable standard — the same for every project that
  adopts skill-os. This file is the opposite: it is YOURS, and no two projects share it. Keeping
  them apart means you can pull an improved guidebook without merge conflicts, and your platform
  decisions are never at risk of being overwritten.

  Guidebook §17 points here. Several guidebook rules are principles until this file answers them:
    §2.2  classification corroboration  <- needs "Data classification tooling"
    §7.3  event-triggered, not polled    <- needs "Event-trigger mechanism"
    §11.2 post-deploy verification       <- needs "Deploy commands"
    §5.3  use shared packages            <- needs "Shared internal packages"

  Delete a section only if it genuinely does not apply, and say why. An empty section is reported
  as a finding by /so-best-practice-audit — that is intentional. Vague answers are worse than
  absent ones, because they look configured.
-->

**Project:** <name>
**Stack:** <e.g. Python + dbt + BigQuery on GCP, or TypeScript + Postgres on Fly.io>
**Last reviewed:** <YYYY-MM-DD>

---

## 1. Environment separation

*Referenced by Guidebook §2.1 (intake), §4.1 (definition of ready).*

How dev, QA/stage, and production are kept apart, and the canonical target for a new service.

<!--
  Answer concretely enough that someone can tell whether a given object is prod. Name the actual
  mechanism: separate cloud projects, a database prefix, a namespace, a branch-per-env convention.

  Example:
    Separate GCP projects: acme-dev, acme-stage, acme-prod. Never cross-reference between them.
    New services default to acme-dev until they have a runbook and an owner.
    Prod datasets are prefixed `p_`; anything unprefixed is not prod.
-->

<!-- your answer -->

---

## 2. Event-trigger mechanism

*Referenced by Guidebook §7.3 (prefer event-driven over polling).*

The platform's concrete way to run work when data changes, instead of polling on a tight schedule.

<!--
  §7.3 says "prefer event-triggered over polled" but cannot say HOW on your stack. Without this,
  nobody can tell whether a design complies.

  Name the primitive and the anti-pattern it replaces. Examples by stack:
    - Pub/Sub topic + push subscription  (not a per-minute Cloud Scheduler job)
    - S3 event notification -> SQS -> Lambda  (not a bucket-listing cron)
    - Postgres LISTEN/NOTIFY or logical replication slot  (not a polling SELECT loop)
    - Kafka consumer group  (not a batch re-read)
    - A change-data-capture stream with a conditional task guard

  Also state what IS legitimately scheduled: work that genuinely runs on a calendar
  (month-end close, a fixed nightly window).
-->

<!-- your answer -->

---

## 3. Deploy commands

*Referenced by Guidebook §2.6 (rollout inventory), §11.2 (deployment standards).*

The real command per artifact type — **and what each one does not cover.**

<!--
  The "does NOT cover" column is the point of this table. Half-deployed changes hide in exactly
  this gap: an app-deploy command that silently does not apply schema migrations, so the app
  ships and the database does not. Write the gaps down and the rollout inventory (§2.6) becomes
  mechanical instead of remembered.
-->

| Artifact | Command | Does NOT cover |
|---|---|---|
| <app / service> | <command> | <e.g. schema migrations, secrets, grants> |
| <schema / migrations> | <command> | |
| <scheduled jobs> | <command> | |
| <config / secrets> | <command> | |
| <infrastructure> | <command> | |

**Manual steps not covered by any command above:**

<!-- list them, or "none" — an undocumented manual step is the operational risk §1.3 warns about -->

---

## 4. Data classification tooling

*Referenced by Guidebook §1.1 (restricted data), §2.2 (corroboration).*

The automated classification the platform offers, used read-only to corroborate a developer's
self-attestation about restricted data.

<!--
  The self-attestation in §2.2 is authoritative and always runs. This is the second signal that
  can only STRENGTHEN the gate, never downgrade it.

  Name the read API and the field that indicates sensitivity. Examples:
    - BigQuery: policy tags / data catalog taxonomy on column metadata
    - AWS: Macie findings, read via GetFindings
    - Postgres: pgcrypto column comments or an in-house classification table
    - None available: say so explicitly. Corroboration then degrades to attestation-only, which
      is a documented state, not a gap to hide.

  MUST be read-only. Do not trigger an on-demand classification scan from a review workflow.
-->

<!-- your answer, or "none available — attestation only" -->

---

## 5. Shared internal packages

*Referenced by Guidebook §5.3.*

The canonical packages to use instead of hand-rolling platform access, auth, or UI.

<!--
  This turns "you reimplemented something we already have" from a style opinion into an auditable
  finding. List package name -> what it owns. If the org has none yet, say "none" — that is a
  real answer and stops the audit inventing one.

  Example:
    @acme/db-client   -> connection pooling, query tagging, retry
    @acme/auth        -> session verification, role checks
    @acme/ui          -> design tokens, components, env banner
-->

<!-- your answer, or "none" -->

---

## 6. Reference implementations

*Referenced by Guidebook §1.2 (prefer existing capability).*

In-house examples worth copying, with links.

<!--
  Prefer-native (§1.2) only works if the agent can find the prior art. Point at the repo or path
  that does each thing correctly, so the next implementation composes instead of reinventing.

  Example:
    Event-driven pipeline -> github.com/acme/order-events (the §7.3 reference)
    Service scaffold      -> github.com/acme/service-template
-->

<!-- your answer -->

---

## 7. Project-specific additions

Anything the guidebook does not cover that this stack requires. Optional.

<!-- your answer, or delete this section -->
