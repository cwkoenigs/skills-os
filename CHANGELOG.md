# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Skills are versioned as a collection: a release here is a release of every `so-*` skill.

## [Unreleased]

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
