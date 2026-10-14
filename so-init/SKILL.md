---
name: so-init
description: "Adopt skill-os into a project — runs `ds new` or `ds migrate` so the repo gets its docs, manifest and pre-push hook from the canon, then detects the stack and git host, interviews for the platform standards (Guidebook §17), and writes shared/platform.md and a CI config for the detected provider. Run once per project. Triggers: so-init, init skill-os, adopt skill-os, set up skill-os, configure platform standards, fill in section 17, platform.md, onboard this repo, bootstrap the guidebook, generate CI, set up CI, add a CI config."
user-invocable: true
---

# so-init (adopt skill-os into a project)

Turn a generic skill-os checkout into one configured for **this** project. The guidebook is
stack-agnostic and never edited; this skill produces the two project-owned artifacts it
depends on:

| Artifact | Answers | Source |
|---|---|---|
| `shared/platform.md` | six platform sections | Guidebook §17 |
| CI config for the detected provider | how the checks run unattended | `references/ci-templates.md` |

Run once per project, then re-run any time the stack changes. It writes at most two files (plus
regenerating vendored copies) — it does not touch skills, `AGENTS.md`, or the guidebook.

**Nothing here is shipped pre-decided.** A hardcoded `.gitlab-ci.yml` would be one org's assumption
imposed on every adopter; a hardcoded platform appendix would be one stack's. Both are detected and
generated instead.

## Prerequisites

- `ds` with the knowledge-system verbs (`ds new`, `ds migrate`, `ds reconcile`, `ds canon`) on the
  PATH, and a canon checkout reachable (`$DS_CANON` or `../canon`). If either is missing, say so
  and continue with the platform interview only; do not fabricate a manifest.
- `platform.example.md` is present in this skill's folder (the vendored template; it is the
  authoritative section list — read it, don't reproduce it from memory).
- `references/ci-templates.md` is present (the per-provider CI configs).
- You are in the repo being configured.

## Workflow

### Step 0a: Give the repository its docs, manifest, and hook (through `ds`, never by hand)

The repository's README, AGENTS.md, DECISIONS.md, `.ds/manifest.toml`, interview transcript, and
pre-push hook come from the `ds` interview, which asks eight questions with defaults detected from
the files. Do not write any of those files yourself.

1. If `.ds/manifest.toml` exists, the repo is already in the system: run `ds reconcile` and report
   pending standards; skip to Step 0.
2. If the repo has code but no manifest: run `ds migrate .` (old docs are kept under `.ds/legacy/`).
3. If the directory is new: run `ds new <name> --dir .`.
4. Report the line `ds` prints (how many standards apply, adopted, declined) before continuing.

The platform standards below (Guidebook §17) are the one thing the interview does not cover yet;
they stay in `shared/platform.md` until they become local docs of the repo.

### Step 0: Check what already exists

1. If `shared/platform.md` exists, this project is already initialized. Show which of the six
   sections are filled vs empty, and whether a CI config exists, then offer: **update a section**,
   **generate CI only**, **re-run fully**, or **stop**. Do not silently overwrite existing answers.
2. Read the vendored `platform.example.md` to get the current section list and the guidance comments
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
Step 4 — `github.com` → Actions, a GitLab host → GitLab CI, `bitbucket.org` → Pipelines, no remote →
offer a local hook), and whether CI config and deploy config disagree about commands — that
disagreement is worth surfacing.

**Report the detection before interviewing.** State what you found, what you inferred, and what you
could not determine. Present inferences as inferences.

### Step 2: Interview the gaps only

Use the question tool. Ask about what detection could not settle; confirm inferences in bulk rather
than one at a time. Order matters — start with what you know least.

Cover the six `platform.md` sections. Two deserve extra care:

- **Deploy commands (§3)** — the *"does NOT cover"* column is the point of the table, and nobody
  volunteers it. Ask directly: *"When you run `<detected deploy command>`, what does it NOT apply?
  Schema migrations? Secrets? Grants? Scheduled jobs?"* Half-deployed changes hide precisely here.
  If migrations live in a separate directory from the app, that is almost always a second deploy
  path — confirm it.
- **Event-trigger mechanism (§2)** — ask what runs work when data changes, and what is *legitimately*
  scheduled on a calendar. If the honest answer is "we poll today," record that as the current state
  plus the intended target; do not write an aspiration as if it were the standard.

**"None" and "not available" are valid answers** for shared packages and reference
implementations. Record them explicitly. An honest "none" stops the audit from inventing
one; a vague placeholder is worse than an empty section because it looks configured.

**⚠️ STOP:** Present the drafted `platform.md` for review before writing. It becomes the standard
the audit skill enforces; a wrong answer here is worse than an empty one, because it will be cited
as settled.

### Step 3: Write the platform file

On approval:

1. **`shared/platform.md`** — from the vendored template's structure. Fill the `**Project:**`,
   `**Stack:**`, and `**Last reviewed:**` header. Keep each section's `*Referenced by Guidebook §X*`
   line so the traceability survives. Strip the template's instructional `<!-- -->` guidance
   comments; keep your answers as prose and tables. Delete a section only if the user said it does
   not apply, and say why inline.
2. Run `./build.sh` so `platform.md` is vendored into `so-best-practice-audit/references/` (this
   replaces the NOT-CONFIGURED stub).

### Step 4: Generate the CI config for the detected provider

The checks themselves live in `tests/verify.sh` — one runner, provider-agnostic. A CI config is a
thin wrapper around it, so it is generated per-environment rather than shipped.

1. **Resolve the provider** from the Step 1 detection, in this order:
   - An existing CI config in the repo → that provider. **Do not overwrite it**; show the snippet
     and ask whether to add a `verify` job to it.
   - Otherwise the git remote host → `github.com` = Actions, a GitLab host = GitLab CI,
     `bitbucket.org` = Pipelines.
   - No remote, or an unrecognized host → offer the **local git hook**, or nothing.
2. **Confirm before writing.** State the provider, the exact file path, and that it will run
   `./tests/verify.sh` on push. Ask once.
3. **Copy the matching template verbatim** from `references/ci-templates.md`. Do not add check logic
   to it — if a check needs to change it changes in `verify.sh`, and every provider inherits it.
   Never invent a config for a provider the templates do not cover; say it is unsupported and give
   the manual command instead.
4. **Run `./tests/verify.sh`** and report the result. This is the same command CI will run, so a
   green local run is real evidence the generated config will pass.

If the user declines CI, say so plainly and tell them the manual command — do not skip silently and
leave them assuming they are covered.

### Step 5: Report and hand off

State plainly:
- The `ds` outcome from Step 0a: standards applying, adopted, declined, and any pending.
- Which of the six sections are filled, and which the user deferred.
- Which guidebook rules are now auditable that were not: §5.3, §7.3, §11.2.
- Which remain blocked, if any section was left empty.
- The CI provider chosen, the file written, and the `./tests/verify.sh` result.

Then offer once: run `/so-best-practice-audit` on the project to get a first conformance read
against the newly configured standard.

## Rules

- **Never edit `shared/guidebook.md`.** It is the upgradable canonical standard. Everything
  project-specific goes in `platform.md`. If the user wants to change a guidebook rule itself, that
  is a `/so-skills` job, not this one.
- **Never invent platform mechanics, and never invent a CI provider.** If you cannot determine the
  event-trigger primitive or a deploy command, leave the section empty and say so. The build vendors
  a NOT-CONFIGURED stub and the audit reports the gap — that failure mode is deliberate and honest.
  Likewise, if the git host is not one the templates cover, say it is unsupported rather than
  guessing at a config shape. A plausible-sounding fabricated command or config is a liability.
- **Never overwrite an existing CI config.** Show the addition and ask.
- **Detect before asking.** An interview that asks what `package.json` already answers wastes the
  user's time and signals you didn't look.
- **No machine-specific paths** in anything you write (`tests/guard_no_machine_paths.sh` enforces
  it). Use `$HOME`, `~/`, or a `<placeholder>`.

## Stopping Points

- ✋ Step 0: if already initialized, confirm update vs CI-only vs re-run vs stop.
- ✋ Step 3: after drafting, before writing `platform.md` or `AGENTS.md`.
- ✋ Step 4: before writing a CI config, and always before touching an existing one.

## Output

`shared/platform.md` (six sections, Guidebook §17 answered), a CI config for the detected
provider, regenerated vendored copies, and the
`./tests/verify.sh` result — plus a statement of which guidebook rules became auditable and which
remain blocked.
