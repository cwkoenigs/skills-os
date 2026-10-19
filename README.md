# Skills OS

This scaffold follows the folder structure in `IMG_2514.jpeg`. The screenshot
shows file names only; the Markdown contains starter guidance to customize.

## Layout

| Path | Purpose |
| --- | --- |
| `docs/adr/` | Architecture decision records (`/so-changes adr` writes the next one) |
| `shared/` | Source files for common guidance and templates (`platform.md` is project-owned and gitignored) |
| `so-agent-setup` | Register the `ds` MCP server (canon + manifest tools) with Claude Code, Codex, and Cortex Code on this machine, discovering Cortex Code's settings location rather than guessing |
| `so-bug-review-interview` | Clarify and investigate a reported bug |
| `so-capture` | Capture session problems, decisions and gotchas as draft records, then flush them to the canon for review |
| `so-build-feature-interview` | Turn a feature request into an implementation brief |
| `so-changes` | Record local decisions in `DECISIONS.md`, log the changelog, draft announcements, cut releases, propose cross-project insights as canon standards |
| `so-codex-review` | Review code for actionable defects |
| `so-init` | Adopt skill-os into a project: run `ds new`/`ds migrate`, detect the stack, write `shared/platform.md`, generate the CI config |
| `so-install` | Link the so-* skills into Claude Code and Codex on this machine |
| `so-skills` | Create or update skills in the collection |
| `tests/` | Future behavioral checks and fixtures |

Each skill has a `SKILL.md` with a name, description, and concise workflow. The standards a repo is
held to live in the canon (`~/Developer/canon`), split from `shared/guidebook.md`; `ds-next reconcile`
checks a repo against them. Shipped changes are logged in `CHANGELOG.md`.
The empty reference and test directories are preserved with `.gitkeep` files.

## Shared resources

Run from the repository root:

```bash
./build.sh
```

The script copies `shared/cadence-core.md` into `so-bug-review-interview/`,
`so-build-feature-interview/`, and `so-skills/`, and `shared/platform.example.md` into `so-init/`.
Each copy starts with a `GENERATED FILE` banner naming its source. Edit the shared source files and
rerun the script; changes made directly to those copies will be overwritten.

The build only synchronizes local files. Installation is a separate step.
