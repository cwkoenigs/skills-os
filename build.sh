#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

for skill in so-bug-review-interview so-build-feature-interview so-skills; do
  cp "$project_root/shared/cadence-core.md" "$project_root/$skill/cadence-core.md"
done

cp "$project_root/shared/platform.example.md" "$project_root/so-init/platform.example.md"

printf 'Shared skill resources synchronized.\n'
