#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Copy a shared source into a skill folder, prefixed with a banner that names
# the source so nobody edits the generated copy by hand.
generate() {
  local source="$1" target="$2"
  mkdir -p "$(dirname -- "$project_root/$target")"
  {
    printf '<!-- GENERATED FILE — do not edit. Source: %s. Run ./build.sh to regenerate. -->\n\n' "$source"
    cat "$project_root/$source"
  } > "$project_root/$target"
}

for skill in so-bug-review-interview so-build-feature-interview so-skills; do
  generate shared/cadence-core.md "$skill/cadence-core.md"
done

generate shared/platform.example.md so-init/platform.example.md
generate shared/guidebook.md so-best-practice-audit/references/guidebook.md

# The audit skill needs the project's own platform standards. Bundle them when
# the project has written shared/platform.md; otherwise bundle the
# NOT CONFIGURED stub so the audit reports the §17 gap instead of guessing.
if [ -f "$project_root/shared/platform.md" ]; then
  generate shared/platform.md so-best-practice-audit/references/platform.md
else
  generate shared/platform.notconfigured.md so-best-practice-audit/references/platform.md
fi

printf 'Shared skill resources synchronized.\n'
