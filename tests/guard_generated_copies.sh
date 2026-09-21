#!/usr/bin/env bash
# guard_generated_copies.sh — prove the committed generated copies match a fresh build.
#
# shared/cadence-core.md and shared/guidebook.md are vendored into consumer skill folders by
# ./build.sh. A stale copy is a silent wrong answer: the consuming skill reads the copy, not the
# source, so it would enforce an outdated standard without erroring. This guard makes that
# impossible to merge.
#
# Method: snapshot the skill tree BEFORE building, run ./build.sh, then compare the files build.sh
# says it wrote against the snapshot. Order matters — snapshot first, or the build overwrites the
# very staleness being tested for.
#
# Deliberately git-independent: a `git diff` check would pass vacuously on a file that was never
# added, which is exactly a case this guard must catch.
# Written for bash 3.2 (macOS default): no mapfile, no associative arrays.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
snapshot="$work/before"
targets="$work/targets"
mkdir -p "$snapshot"

# 1. Snapshot the current skill tree (small; markdown only) BEFORE anything is regenerated.
for dir in so-*/; do
  [ -d "$dir" ] || continue
  mkdir -p "$snapshot/$dir"
  cp -R "$dir." "$snapshot/$dir"
done

# 2. Regenerate, capturing which files build.sh claims to write.
if ! ./build.sh 2>/dev/null | sed -n 's/^synced -> //p' > "$targets"; then
  echo "GUARD FAIL: ./build.sh exited non-zero" >&2
  exit 1
fi

if [ ! -s "$targets" ]; then
  echo "GUARD FAIL: build.sh reported no generated files — did its output format change?" >&2
  exit 1
fi

# 3. Compare each regenerated file against its pre-build snapshot.
failed=0
count=0
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  count=$((count + 1))

  if [ ! -f "$snapshot/$rel" ]; then
    echo "MISSING: $rel was not committed — run ./build.sh and commit it"
    failed=1
  elif ! cmp -s "$snapshot/$rel" "$rel"; then
    echo "STALE: $rel differed from a fresh ./build.sh run"
    failed=1
  else
    echo "PASS: $rel is in sync with source"
  fi

  # Every generated file must carry the banner, so a hand-edit is obvious on sight.
  if ! head -1 "$rel" | grep -q 'GENERATED FILE'; then
    echo "VIOLATION: $rel is missing the GENERATED FILE banner"
    failed=1
  fi
done < "$targets"

if [ "$failed" -ne 0 ]; then
  echo
  echo "GUARD FAIL: generated copies are stale or missing." >&2
  echo "Run ./build.sh and commit the result. Never hand-edit a generated copy." >&2
  exit 1
fi

echo "GUARD OK: $count generated copies match source and carry the banner"
