#!/usr/bin/env bash
# build.sh — sync shared sources into each skill that depends on them.
#
# shared/*.md are the single sources of truth. Skills install individually by name from the remote,
# so a bare repo-root file won't co-install with a skill. This script copies each source verbatim
# into its dependent skill folder (with a generated-header banner) so each installed skill is
# self-contained:
#   - shared/cadence-core.md      -> each cadence skill's cadence-core.md
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

TEMPLATE_CONSUMER="so-init"                   # bundles the platform template it fills in

sync() {
  local src="$1" dest="$2" src_label="$3"
  local banner="<!-- GENERATED FILE — do not edit. Source: $src_label. Run ./build.sh to regenerate. -->"
  mkdir -p "$(dirname "$dest")"
  { printf '%s\n\n' "$banner"; cat "$src"; } > "$dest"
  echo "synced -> ${dest#"$REPO_DIR"/}"
}

CADENCE_SRC="$REPO_DIR/shared/cadence-core.md"
TEMPLATE_SRC="$REPO_DIR/shared/platform.example.md"

for src in "$CADENCE_SRC" "$TEMPLATE_SRC"; do
  [ -f "$src" ] || { echo "error: source not found: $src" >&2; exit 1; }
done

for skill in "${CADENCE_CONSUMERS[@]}" "$TEMPLATE_CONSUMER"; do
  [ -d "$REPO_DIR/$skill" ] || { echo "error: consumer skill folder missing: $skill" >&2; exit 1; }
done

for skill in "${CADENCE_CONSUMERS[@]}"; do
  sync "$CADENCE_SRC" "$REPO_DIR/$skill/cadence-core.md" "shared/cadence-core.md"
done

sync "$TEMPLATE_SRC" "$REPO_DIR/$TEMPLATE_CONSUMER/platform.example.md" "shared/platform.example.md"

echo "Done. Commit the generated copies so the remote install ships them."
