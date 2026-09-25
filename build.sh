#!/usr/bin/env bash
# build.sh — sync shared sources into each skill that depends on them.
#
# shared/*.md are the single sources of truth. Skills install individually by name from the remote,
# so a bare repo-root file won't co-install with a skill. This script copies each source verbatim
# into its dependent skill folder (with a generated-header banner) so each installed skill is
# self-contained:
#   - shared/cadence-core.md      -> each cadence skill's cadence-core.md
#   - shared/guidebook.md         -> so-best-practice-audit/references/guidebook.md
#   - shared/platform.md          -> so-best-practice-audit/references/platform.md
#   - shared/platform.example.md  -> so-init/platform.example.md
#
# platform.md is PROJECT-OWNED and may not exist yet. When it is absent, an explicit
# NOT-CONFIGURED stub is vendored instead, so the audit skill reports the gap as a finding rather
# than silently passing on a missing standard.
#
# Run this before every commit that touches a shared/ source, and commit the generated copies.
# Run ./tests/guard_generated_copies.sh to confirm the committed copies match a fresh run.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Skills that consume the shared cadence. This list is a real decision (not everything needs it),
# so it stays explicit — but a missing folder is a hard error rather than a silent skip.
CADENCE_CONSUMERS=(
  "so-build-feature-interview"
  "so-bug-review-interview"
  "so-skills"
)

GUIDEBOOK_CONSUMER="so-best-practice-audit"   # bundles the canonical guidebook + platform standards
TEMPLATE_CONSUMER="so-init"                   # bundles the platform template it fills in

sync() {
  local src="$1" dest="$2" src_label="$3"
  local banner="<!-- GENERATED FILE — do not edit. Source: $src_label. Run ./build.sh to regenerate. -->"
  mkdir -p "$(dirname "$dest")"
  { printf '%s\n\n' "$banner"; cat "$src"; } > "$dest"
  echo "synced -> ${dest#"$REPO_DIR"/}"
}

CADENCE_SRC="$REPO_DIR/shared/cadence-core.md"
GUIDEBOOK_SRC="$REPO_DIR/shared/guidebook.md"
PLATFORM_SRC="$REPO_DIR/shared/platform.md"
TEMPLATE_SRC="$REPO_DIR/shared/platform.example.md"

for src in "$CADENCE_SRC" "$GUIDEBOOK_SRC" "$TEMPLATE_SRC"; do
  [ -f "$src" ] || { echo "error: source not found: $src" >&2; exit 1; }
done

for skill in "${CADENCE_CONSUMERS[@]}" "$GUIDEBOOK_CONSUMER" "$TEMPLATE_CONSUMER"; do
  [ -d "$REPO_DIR/$skill" ] || { echo "error: consumer skill folder missing: $skill" >&2; exit 1; }
done

for skill in "${CADENCE_CONSUMERS[@]}"; do
  sync "$CADENCE_SRC" "$REPO_DIR/$skill/cadence-core.md" "shared/cadence-core.md"
done

sync "$GUIDEBOOK_SRC" "$REPO_DIR/$GUIDEBOOK_CONSUMER/references/guidebook.md" "shared/guidebook.md"
sync "$TEMPLATE_SRC" "$REPO_DIR/$TEMPLATE_CONSUMER/platform.example.md" "shared/platform.example.md"

# Project-owned platform standards: vendor the real file, or an honest stub when unconfigured.
PLATFORM_DEST="$REPO_DIR/$GUIDEBOOK_CONSUMER/references/platform.md"
if [ -f "$PLATFORM_SRC" ]; then
  sync "$PLATFORM_SRC" "$PLATFORM_DEST" "shared/platform.md"
else
  mkdir -p "$(dirname "$PLATFORM_DEST")"
  cat > "$PLATFORM_DEST" <<'STUB'
<!-- GENERATED FILE — do not edit. Source: none (shared/platform.md absent). Run ./build.sh to regenerate. -->

# Platform Standards — NOT CONFIGURED

`shared/platform.md` does not exist in this project, so Guidebook §17 is unanswered.

**Consequence for auditing.** These guidebook rules cannot be assessed concretely. Report each as a
finding against §17 — do NOT invent platform mechanics:

| Guidebook rule | Blocked because |
|---|---|
| §5.3 use shared packages | no canonical package list declared |
| §7.3 event-triggered, not polled | no event-trigger mechanism declared |
| §11.2 post-deploy verification | no deploy commands declared |

**Remediation.** Run `/so-init`, or copy `shared/platform.example.md` to `shared/platform.md` and
fill it in, then run `./build.sh`.
STUB
  echo "synced -> ${PLATFORM_DEST#"$REPO_DIR"/}"
  echo "  note: NOT-CONFIGURED stub used — shared/platform.md is absent (run /so-init)"
fi

echo "Done. Commit the generated copies so the remote install ships them."
