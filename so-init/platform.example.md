<!-- GENERATED FILE — do not edit. Source: shared/platform.example.md. Run ./build.sh to regenerate. -->

# Platform Standards

**Project:** **Stack:** <e.g. Python + dbt + BigQuery on GCP, or TypeScript + Postgres on Fly.io> **Last reviewed:**

---

## 1. Environment separation

*Referenced by Guidebook §2.1 (intake), §4.1 (definition of ready).*

How dev, QA/stage, and production are kept apart, and the canonical target for a new service.

---

## 2. Event-trigger mechanism

*Referenced by Guidebook §7.3 (prefer event-driven over polling).*

The platform's concrete way to run work when data changes, instead of polling on a tight schedule.

---

## 3. Deploy commands

*Referenced by Guidebook §2.6 (rollout inventory), §11.2 (deployment standards).*

The real command per artifact type — and what each one does not cover.

| Artifact | Command | Does NOT cover |
|---|---|---|
| <app / service> | | <e.g. schema migrations, secrets, grants> |
| <schema / migrations> | | |
| <config / secrets> | | |

Manual steps not covered by any command above:

---

## 4. Data classification tooling

*Referenced by Guidebook §1.1 (restricted data), §2.2 (corroboration).*

The automated classification the platform offers, used read-only to corroborate a developer's self-attestation about restricted data.

---

## 5. Shared internal packages

*Referenced by Guidebook §5.3.*

The canonical packages to use instead of hand-rolling platform access, auth, or UI.

---

## 6. Reference implementations

*Referenced by Guidebook §1.2 (prefer existing capability).*

In-house examples worth copying, with links.

---

## 7. Project-specific additions

Anything the guidebook does not cover that this stack requires. Optional.
