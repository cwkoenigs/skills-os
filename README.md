# Skills OS

This scaffold follows the folder structure in `IMG_2514.jpeg`. The screenshot
shows file names only; the Markdown contains starter guidance to customize.

## Layout

| Path | Purpose |
| --- | --- |
| `docs/adr/` | Architecture decision records (`/so-changes adr` writes the next one) |
| `shared/` | Source files for common guidance and templates (`platform.md` is project-owned and gitignored) |
| `so-best-practice-audit` | Review a project against relevant practices |
| `so-bug-review-interview` | Clarify and investigate a reported bug |
| `so-capture` | Capture session problems, decisions and gotchas as draft records, then flush them to the team knowledge repo for review |
| `so-build-feature-interview` | Turn a feature request into an implementation brief |
| `so-changes` | Record ADRs, log the changelog, draft announcements, cut releases, capture cross-project insights |
| `so-codex-review` | Review code for actionable defects |
| `so-init` | Adopt skill-os into a project: detect the stack, write `shared/platform.md`, generate the CI config |
| `so-install` | Link the so-* skills into Claude Code and Codex on this machine |
| `so-skills` | Create or update skills in the collection |
| `tests/` | Future behavioral checks and fixtures |

Each skill has a `SKILL.md` with a name, description, and concise workflow. The standard they are
held to is `shared/guidebook.md` (Software Project Best Practices Guidebook); run
`/so-best-practice-audit` to check work against it. Shipped changes are logged in `CHANGELOG.md`.
The empty reference and test directories are preserved with `.gitkeep` files.

## Shared resources

Run from the repository root:

```bash
./build.sh
```

The script copies `shared/cadence-core.md` into `so-bug-review-interview/`,
`so-build-feature-interview/`, and `so-skills/`. It also copies
`shared/platform.example.md` into `so-init/` and `shared/guidebook.md` into
`so-best-practice-audit/references/`. It also bundles the project's platform
standards into that references directory: `shared/platform.md` when the project
has written one, otherwise a NOT CONFIGURED stub so the audit reports the gap
instead of guessing. Each copy starts with a `GENERATED FILE` banner naming its source. Edit the
shared source files and rerun the script; changes made directly to those copies
will be overwritten.

The build only synchronizes local files. Installation is a separate step.
