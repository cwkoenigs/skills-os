# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Skills are versioned as a collection: a release here is a release of every `so-*` skill.

## [Unreleased]

### Added
- skills-os is in the knowledge system: `.ds/manifest.toml` (tags skills, markdown, bash; every
  standard pending until the owner adopts it), a standards section in AGENTS.md, a DECISIONS.md and
  the pre-push hook, written by `ds-next adopt`. The manifest declares what this repo provides to the
  others (the nine `so-*` skills and their `SKILL.md` paths) and what it uses (canon's `index.json` and
  `install.sh`, `ds-next new` and `ds-next adopt`), for the cross-repo graph canon's pipeline compiles
  (canon adr-002).

### Changed
- `so-capture` reads where to publish from the machine's one config, `~/.ds/config.toml` (`[world]`: `host`, `group`, `token_env`; `[capture]`: `repo`, `branch`, `dir`), which canon's `install.sh` writes, and flushes as a GitHub pull request at home or a GitLab merge request at work. The older `~/.config/so-capture/config.toml` is still read; with neither, the canon checkout's remote decides. Drafts live in `.ds/captures/`, where ds-next's `capture` tool writes too, so one flush takes both. **User-visible:** a draft in `.captures/` is no longer found; move it to `.ds/captures/`.

### Removed
- `so-ds-port`: it ported the knowledge system into the old `ds-cli`; `ds-next` replaced `ds-cli`, so there is nothing left to port. (303ca7c)
- `so-best-practice-audit`: it audited work against the bundled 1,300-line guidebook. The guidebook was split into canon standards, and `ds-next reconcile` checks a repo against the standards it adopted, so the audit duplicated the canon. The guidebook stays in `shared/` as the cadence's citation source. **User-visible:** `/so-best-practice-audit` no longer exists; use `ds-next reconcile` and `canon_list`. (303ca7c)

### Changed
- `build.sh` no longer bundles the guidebook or the platform stub into a skill; `verify.sh`, README and AGENTS.md follow. (303ca7c)

### Added
- `so-install`: links every `so-*` skill from this checkout into Claude Code (`~/.claude/skills`) and Codex (`~/.codex/skills`) and verifies the links; `so-codex-review` is optional (`--all`). (95f8667; backfilled 2026-10-19, it had shipped unlogged.)
- `so-ds-port`: ports the knowledge-system verbs into the team's real ds-cli by reading its structure and planning first; no git merge, no push.
- `so-agent-setup`: registers `ds serve-mcp` with Claude Code, Codex, and Cortex Code and verifies `manifest_status`; the Cortex Code location is discovered on the machine, never guessed.

### Changed
- `so-init`, `so-changes`, `so-capture`, `so-best-practice-audit` retargeted to the `ds` knowledge system: repos get docs, manifest and hook from `ds new`/`ds migrate`; local decisions go in `DECISIONS.md`; insights and captures are proposed to the canon; audits read adoption status with `ds canon list` and cite standards by id. The bundled guidebook remains the fallback for repos outside the system.

### Added

- CI: `.github/workflows/verify.yml` runs `./tests/verify.sh` on every push and pull request,
  so the committed generated copies are proven fresh unattended (Guidebook §11.1).
- `verify.sh` frontmatter check: every `SKILL.md` must parse with a name matching its folder, a
  description long enough to trigger on, and `user-invocable: true`.
- ADRs: 001 records the retirement of the restricted-data gate (2026-09-25), 002 the one-runner,
  thin-wrapper CI design. `docs/adr/000-template.md` is the template `/so-changes adr` uses.
- This changelog.

### Changed

- so-bug-review-interview, so-build-feature-interview and so-codex-review descriptions now carry
  triggers, like the other skills.
- so-capture: `user-invocable: true`; the data gate cites Guidebook §9.2 instead of the retired
  internal-only review track; the false "vendored" marker is gone; the build handoff moved to
  `docs/so-capture-handoff.md` so the skill folder ships only what installers need.
- so-codex-review: the Codex path prepend is `$CODEX_BIN_DIR`, defaulting to the Homebrew path.
- so-init: steps numbered 0 to 5 without a gap; ci-templates.md points at the right step.
- README: so-changes and so-init rows describe what the skills now do; the guidebook is linked.
- AGENTS.md: skill count no longer hardcoded; owner named.
- `verify.sh` readme-table check is anchored on a table row, not a bare mention.

### Fixed

- README skills table was missing so-capture (readme-table check failed).
