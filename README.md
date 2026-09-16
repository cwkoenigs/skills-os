# Skills OS

This scaffold follows the folder structure in `IMG_2514.jpeg`. The screenshot
shows file names only; the Markdown contains starter guidance to customize.

## Layout

| Path | Purpose |
| --- | --- |
| `docs/adr/` | Architecture decision records |
| `shared/` | Source files for common guidance and templates |
| `so-best-practice-audit/` | Review a project against relevant practices |
| `so-bug-review-interview/` | Clarify and investigate a reported bug |
| `so-build-feature-interview/` | Turn a feature request into an implementation brief |
| `so-changes/` | Summarize a set of code changes |
| `so-codex-review/` | Review code for actionable defects |
| `so-init/` | Establish project context and conventions |
| `so-skills/` | Create or update skills in the collection |
| `tests/` | Future behavioral checks and fixtures |

Each skill has a `SKILL.md` with a name, description, and concise workflow.
The empty reference and test directories are preserved with `.gitkeep` files.

## Shared resources

Run from the repository root:

```bash
./build.sh
```

The script copies `shared/cadence-core.md` into `so-bug-review-interview/`,
`so-build-feature-interview/`, and `so-skills/`. It also copies
`shared/platform.example.md` into `so-init/` and `shared/guidebook.md` into
`so-best-practice-audit/references/`. Edit the shared source files and
rerun the script; changes made directly to those copies will be overwritten.

The build only synchronizes local files. Installation is a separate step.
