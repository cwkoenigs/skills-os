#!/usr/bin/env bash
# verify.sh — run every skill-os check. One command, one exit code.
#
# This is the single source of check logic. It runs identically on a laptop and in any CI provider,
# so a generated CI config is a thin wrapper that calls this file and nothing more. That is
# deliberate: provider configs are generated per-environment (see /so-init), and duplicating check
# logic into them would give every provider its own subtly different idea of "passing".
#
# Usage:
#   ./tests/verify.sh           run all checks
#   ./tests/verify.sh --list    print check names and exit
#
# Written for bash 3.2 (macOS default): no mapfile, no associative arrays.

set -uo pipefail   # deliberately NOT -e: a failing check must be recorded, not abort the run

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

CHECKS="generated-copies machine-paths registry readme-table frontmatter skill-size platform-split"

if [ "${1:-}" = "--list" ]; then
  for c in $CHECKS; do echo "$c"; done
  exit 0
fi

pass_count=0
fail_names=""

run() {
  local name="$1"; shift
  local out rc
  out="$("$@" 2>&1)"; rc=$?
  if [ "$rc" -eq 0 ]; then
    printf 'PASS  %s\n' "$name"
    pass_count=$((pass_count + 1))
  else
    printf 'FAIL  %s\n' "$name"
    printf '%s\n' "$out" | sed 's/^/      /'
    fail_names="$fail_names $name"
  fi
}

# --- 1/2: the two guards own their own logic and self-test their patterns ---------------------
run generated-copies ./tests/guard_generated_copies.sh
run machine-paths     ./tests/guard_no_machine_paths.sh

# --- 3: the install list is derived from the filesystem, so prove the derivation runs and that
#        every so-*/ directory is actually a skill ------------------------------------------------
check_registry() {
  ./install.sh --list >/dev/null || return 1
  local rc=0
  for dir in so-*/; do
    [ -d "$dir" ] || continue
    if [ ! -f "$dir/SKILL.md" ]; then
      echo "$dir has no SKILL.md"; rc=1
    fi
  done
  return $rc
}
run registry check_registry

# --- 4: a skill missing from the README table is undiscoverable to a teammate.
#        Anchored on a table row, not a bare mention: prose that names the skill must not pass. --
check_readme_table() {
  local rc=0
  for dir in so-*/; do
    local name="${dir%/}"
    grep -qE "^\| \`$name\` \|" README.md || { echo "$name missing from the README skills table"; rc=1; }
  done
  return $rc
}
run readme-table check_readme_table

# --- 4b: every SKILL.md declares the contract the runtime loads it by: frontmatter whose name
#         matches the folder, a non-empty description, and user-invocable set. Parsed, not grepped. --
check_frontmatter() {
  python3 - <<'PY'
import pathlib, re, sys
rc = 0
for f in sorted(pathlib.Path('.').glob('so-*/SKILL.md')):
    text = f.read_text()
    m = re.match(r'---\n(.*?)\n---\n', text, re.S)
    if not m:
        print(f"{f}: no YAML frontmatter"); rc = 1; continue
    fm = {}
    for line in m.group(1).splitlines():
        k, _, v = line.partition(':')
        fm[k.strip()] = v.strip().strip('"')
    folder = f.parent.name
    if fm.get('name') != folder:
        print(f"{f}: name '{fm.get('name')}' != folder '{folder}'"); rc = 1
    if len(fm.get('description', '')) < 40:
        print(f"{f}: description missing or too short to trigger on"); rc = 1
    if fm.get('user-invocable') != 'true':
        print(f"{f}: user-invocable is not 'true'"); rc = 1
sys.exit(rc)
PY
}
run frontmatter check_frontmatter

# --- 5: routers stay thin; detail belongs in references/ -----------------------------------------
check_skill_size() {
  local rc=0
  for f in so-*/SKILL.md; do
    local lines; lines=$(wc -l < "$f" | tr -d ' ')
    if [ "$lines" -ge 500 ]; then
      echo "$f is $lines lines (limit 500) — move detail into references/"; rc=1
    fi
  done
  return $rc
}
run skill-size check_skill_size

# --- 6: the upstream standard must stay free of project specifics. If a project edits
#        shared/guidebook.md it has forked the standard and can never pull an improvement. --------
check_platform_split() {
  local rc=0
  [ -f shared/platform.example.md ] \
    || { echo "shared/platform.example.md missing"; rc=1; }
  grep -q 'shared/platform.md' shared/guidebook.md \
    || { echo "guidebook §17 no longer points at shared/platform.md"; rc=1; }
  grep -q 'references/platform.md' so-best-practice-audit/SKILL.md \
    || { echo "so-best-practice-audit does not read references/platform.md"; rc=1; }
  return $rc
}
run platform-split check_platform_split

# --- summary --------------------------------------------------------------------------------------
total=$(echo "$CHECKS" | wc -w | tr -d ' ')
echo
if [ -n "$fail_names" ]; then
  echo "$pass_count/$total passed — FAILED:$fail_names"
  exit 1
fi
echo "$pass_count/$total passed"
