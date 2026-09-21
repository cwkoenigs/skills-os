---
name: so-init
description: "Adopt skill-os into a project — detects the stack and git host, interviews for the platform standards (Guidebook §17) and restricted-data categories (§1.1), then writes shared/platform.md, AGENTS.md, and a CI config for the detected provider. Run once per project. Triggers: so-init, init skill-os, adopt skill-os, set up skill-os, configure platform standards, fill in section 17, platform.md, restricted data categories, onboard this repo, bootstrap the guidebook, generate CI, set up CI, add a CI config."
user-invocable: true
---

# so-init (adopt skill-os into a project)

Turn a generic skill-os checkout into one configured for **this** project. The guidebook is
stack-agnostic and never edited; this skill produces the three project-owned artifacts it
depends on:

| Artifact | Answers | Source |
|---|---|---|
| `shared/platform.md` | seven platform sections | Guidebook §17 |
| `AGENTS.md` restricted-data categories | what counts as restricted here | Guidebook §1.1, §9.1 |
| CI config for the detected provider | how the checks run unattended | `references/ci-templates.md` |

Run once per project, then re-run any time the stack changes. It writes at most three files (plus
regenerating vendored copies) — it does not touch skills or the guidebook.

**Nothing here is shipped pre-decided.** A hardcoded `.gitlab-ci.yml` would be one org's assumption
imposed on every adopter; a hardcoded platform appendix would be one stack's. Both are detected and
generated instead.

## Prerequisites

- `platform.example.md` is present in this skill's folder (the vendored template; it is the
  authoritative section list — read it, don't reproduce it from memory).
- `references/ci-templates.md` is present (the per-provider CI configs).
- You are in the repo being configured.

## Workflow

### Step 0: Check what already exists

1. If `shared/platform.md` exists, this project is already initialized. Show which of the seven
   sections are filled vs empty, and whether a CI config exists, then offer: **update a section**,
   **generate CI only**, **re-run fully**, or **stop**. Do not silently overwrite existing answers.
2. If `AGENTS.md` exists, read it. Preserve everything in it; you are adding or replacing only the
   restricted-data block.
3. Read the vendored `platform.example.md` to get the current section list and the guidance comments
   for each. That file is the contract.

### Step 1: Detect the stack (read-only, before asking anything)

Do the work before the interview. Every fact you find is a question you don't have to ask.

Scan the repo root and one level down for:

| Signal | Suggests |
|---|---|
| `package.json`, `pnpm-lock.yaml`, `next.config.*` | Node / TypeScript; check `scripts` for real test+build commands |
| `pyproject.toml`, `requirements.txt`, `uv.lock` | Python; check `[tool.*]` for the test runner |
| `dbt_project.yml`, `profiles.yml` | dbt; the `target` names are the environments |
| `*.tf`, `terragrunt.hcl` | Terraform; workspaces or dirs are often the env split |
| `Dockerfile`, `compose.yaml`, `*.k8s.yaml`, `helm/` | container deploy path |
| `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile` | CI provider; its jobs name the real commands |
| `Makefile`, `Justfile`, `Taskfile.yml` | the project's own canonical commands — prefer these |
| `serverless.yml`, `fly.toml`, `vercel.json`, `app.yaml` | deploy target and platform |
| `migrations/`, `alembic/`, `flyway/`, `*.sql` in a versioned dir | schema deploy path, usually **separate** from app deploy |
| `README.md`, existing `RUNBOOK.md` | environments, deploy steps, owners |

Also check: `git remote -v` (this identifies the **git host**, which decides the CI provider in
Step 5 — `github.com` → Actions, a GitLab host → GitLab CI, `bitbucket.org` → Pipelines.
