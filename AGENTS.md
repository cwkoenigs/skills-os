# AGENTS.md — skill-os

## Project Overview

`skill-os` is a skill system skeleton: a canonical standard (`shared/guidebook.md`), a change cadence
that executes it (`shared/cadence-core.md`), the `so-*` skills (one folder each; `./install.sh --list --all`
is the current list), a vendoring generator (`build.sh`), and CI guards. Owner: Clark Koenigs
(`cwkoenigs` on GitHub). See `README.md` for the architecture.

## Architecture Boundaries

Policy flows one direction: **guidebook → cadence-core → vendored copies → skill runtime.**

- `shared/` holds the only editable sources of policy.
- `so-*/cadence-core.md` and `so-init/platform.example.md` are **generated**.
  Never edit them. Edit the `shared/` source and run `./build.sh`.
- Skills are flat: `so-<name>/SKILL.md` plus optional `references/`. No cross-skill imports —
  skills reference each other by invocation (`/so-codex-review`), not by file path.

## Directory Map

```
shared/         canonical guidebook + cadence (the only editable policy sources)
so-*/           one directory per skill; SKILL.md required
tests/          shell guards, self-testing
docs/adr/       architecture decision records
build.sh        vendors shared/ sources into consumer skills
install.sh      registers the remote; derives the skill list from the filesystem and
                discovers the manifest path by shape-validated search
```

## Setup

No dependencies beyond `bash`, `git`, and `python3`.

## Required Checks

```bash
./tests/verify.sh
```

Seven checks, one exit code: generated-copies, machine-paths, registry, readme-table, frontmatter, skill-size,
platform-split. Run after changing anything in `shared/` or adding a skill.

`verify.sh` is the single source of check logic. CI configs are **generated per-project** by
`/so-init` and are thin wrappers that call it — never add check logic to a CI config, or each
provider grows its own idea of "passing."

## Coding Standards

- `so-` prefix, kebab-case skill names.
- `SKILL.md` under 500 lines; detail goes in `references/`.
- Frontmatter descriptions are action-oriented and trigger-rich.
- No machine-specific paths — use `$HOME`, `~/`, or a `<placeholder>`.
- No auxiliary docs inside a skill folder (no README, CHANGELOG, or committed audit reports).

## Testing Standards

Guards must **self-test their own patterns** — assert that a known-bad input is caught and a
known-good input is allowed, so a broken guard fails loudly rather than passing vacuously. Prove a
new guard works by feeding it a violation.

Guards assert runnable artifacts, not string presence (Guidebook §10.3).

No allowlists in guards. If a match is legitimate, rewrite the content.

## Security and Privacy Rules

This repo contains policy documents, workflow definitions, and shell scripts. External review is
always available; there is no data-classification question.

Never commit credentials, tokens, or private keys. Check what generator scripts bake into
committed output, not just what is gitignored (Guidebook §9.2).

## Data Rules

None — this repo has no datasets.

## Files Requiring Extra Care

| File | Why |
|---|---|
| `shared/guidebook.md` | Canonical policy. Changing a section number breaks `Canonical: §X` citations in `cadence-core.md`. Renumber both together. |
| `shared/cadence-core.md` | Executed at runtime by three skills. Verify its citations still resolve after any guidebook edit. |
| `build.sh` | Its `synced -> ` output format is parsed by `tests/guard_generated_copies.sh`. |
| `install.sh` | Writes to the user's agent manifest. Must stay idempotent, must never invent a manifest path, and must refuse to overwrite non-JSON. Discovery validates by parsing, not by filename — a name match can write a file the runtime never reads. |

## PR Response Format

- Summary
- Tests run (name the guards and their exit status)
- Risks/limitations
- Files changed

<!-- ds:inherited canon 2026-10-30 -->
## Standards

Standards that apply here, each pending until the owner adopts or declines it in `.ds/manifest.toml` (`/status` in ds-next): [[adr-000]], [[adr-001]], [[adr-002]], [[architecture]], [[change-cadence]], [[cicd]], [[code-review]], [[compliance-rubric]], [[decision-logs]], [[gotcha-green-means-ran]], [[gotcha-proving-claims]], [[gotcha-verify-process]], [[lifecycle]], [[llm-agents]], [[normative-language]], [[operating-principles]], [[repo-naming]], [[review-cadence]], [[security]], [[templates]], [[testing]].
