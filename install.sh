#!/usr/bin/env bash
# install.sh — register the skill-os remote source in an agent runtime's skills manifest.
#
# Nothing about the environment is hardcoded, because every hardcode is a guess that goes stale:
#   - the SKILL LIST is derived from the filesystem (every `so-*/` containing a SKILL.md)
#   - the REMOTE URL is read from git
#   - the MANIFEST PATH is DISCOVERED by searching for a file with the right SHAPE
#
# Why shape and not name: a directory called `.codex` or `.claude` may exist as runtime state
# without being a skill manifest at all. Matching on a name writes a file the runtime never reads —
# a silent no-op that looks like success. So this searches for candidate manifests, then validates
# each one by parsing it, and only ever writes to a manifest that already exists or a path the user
# passed explicitly. It never invents a location.
#
# Usage:
#   ./install.sh                     discover the manifest and install
#   ./install.sh --list              print the derived skill list and exit
#   ./install.sh --all               include OPTIONAL skills too
#   ./install.sh --discover          show every manifest found, and exit
#   ./install.sh --config <path>     write to an explicit manifest path (created if absent)
#   ./install.sh --print             print the JSON entry to stdout, write nothing
#   SKILL_OS_CONFIG=<path> ./install.sh    same as --config
#
# Written for bash 3.2 (macOS default): no mapfile, no associative arrays.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REF="main"

# Skills deliberately NOT installed by default. so-codex-review requires the Codex CLI.
OPTIONAL=("so-codex-review")

# Filenames an agent skill manifest is plausibly called. Candidates only — every hit is still
# shape-validated below, so adding a speculative name here is harmless.
MANIFEST_NAMES="skills.json"

# Directory names never worth descending into.
PRUNE="Library .Trash node_modules .git .cache .npm caches Caches .venv venv site-packages"

INCLUDE_OPTIONAL=false
LIST_ONLY=false
PRINT_ONLY=false
DISCOVER_ONLY=false
CONFIG="${SKILL_OS_CONFIG:-}"

while [ $# -gt 0 ]; do
  case "$1" in
    --all)      INCLUDE_OPTIONAL=true ;;
    --list)     LIST_ONLY=true ;;
    --print)    PRINT_ONLY=true ;;
    --discover) DISCOVER_ONLY=true ;;
    --config)   shift; [ $# -gt 0 ] || { echo "--config needs a path" >&2; exit 2; }; CONFIG="$1" ;;
    -h|--help)  sed -n '2,25p' "$0"; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
  shift
done

is_optional() {
  for o in "${OPTIONAL[@]}"; do [ "$1" = "$o" ] && return 0; done
  return 1
}

# --- derive the skill list from the filesystem ------------------------------------------------
skills=()
for dir in "$REPO_DIR"/so-*/; do
  name="$(basename "$dir")"
  [ -f "$dir/SKILL.md" ] || continue
  if ! $INCLUDE_OPTIONAL && is_optional "$name"; then continue; fi
  skills+=("$name")
done

if [ ${#skills[@]} -eq 0 ]; then
  echo "error: no so-*/SKILL.md found in $REPO_DIR" >&2
  exit 1
fi

if $LIST_ONLY; then
  printf '%s\n' "${skills[@]}"
  exit 0
fi

# --- manifest discovery: search, then validate by shape ---------------------------------------
# Loop 1 finds candidate files. Loop 2 keeps only those that actually parse as a manifest.
# Prints "<path>" per accepted candidate.
discover_manifests() {
  local prune_expr=() d first=true
  for d in $PRUNE; do
    if $first; then prune_expr+=( -name "$d" ); first=false
    else prune_expr+=( -o -name "$d" ); fi
  done

  local name_expr=() n
  first=true
  for n in $MANIFEST_NAMES; do
    if $first; then name_expr+=( -name "$n" ); first=false
    else name_expr+=( -o -name "$n" ); fi
  done

  # Loop 1: candidates by filename, depth-bounded, noisy trees pruned.
  find "$HOME" -maxdepth 4 \
      \( -type d \( "${prune_expr[@]}" \) -prune \) -o \
      \( -type f \( "${name_expr[@]}" \) -print \) 2>/dev/null \
  | while IFS= read -r candidate; do
      # Loop 2: shape validation. A manifest is a JSON object; `remote`, if present, is a list.
      if python3 - "$candidate" <<'PY' 2>/dev/null
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
except Exception:
    sys.exit(1)
if not isinstance(data, dict):
    sys.exit(1)
remote = data.get("remote", [])
sys.exit(0 if isinstance(remote, list) else 1)
PY
      then
        echo "$candidate"
      fi
    done
}

if $DISCOVER_ONLY; then
  found="$(discover_manifests)"
  if [ -z "$found" ]; then
    echo "No agent skill manifest found under \$HOME (searched to depth 4)."
    echo "Use --config <path> to name one explicitly, or --print to see the entry to add by hand."
    exit 1
  fi
  echo "Manifests found (validated as JSON objects):"
  printf '%s\n' "$found" | sed 's/^/  /'
  exit 0
fi

# --- resolve the remote source from git -------------------------------------------------------
REMOTE_SOURCE="$(git -C "$REPO_DIR" remote get-url origin 2>/dev/null || true)"
REMOTE_SOURCE="${REMOTE_SOURCE%.git}"

SKILLS_JSON="$(printf '%s\n' "${skills[@]}" \
  | python3 -c 'import json,sys; print(json.dumps([l.strip() for l in sys.stdin if l.strip()]))')"

if $PRINT_ONLY; then
  REMOTE_SOURCE="${REMOTE_SOURCE:-<add-your-git-remote>}" REF="$REF" SKILLS_JSON="$SKILLS_JSON" \
  python3 - <<'PY'
import json, os
print(json.dumps({
    "source": os.environ["REMOTE_SOURCE"],
    "ref": os.environ["REF"],
    "skills": [{"name": n} for n in json.loads(os.environ["SKILLS_JSON"])],
}, indent=2))
PY
  exit 0
fi

if [ -z "$REMOTE_SOURCE" ]; then
  echo "error: no git 'origin' remote found — add one, or use --print to emit the entry." >&2
  exit 1
fi

# --- resolve the manifest path ----------------------------------------------------------------
if [ -n "$CONFIG" ]; then
  # Explicit path: the user asserted it, so create it if absent.
  mkdir -p "$(dirname "$CONFIG")"
  [ -f "$CONFIG" ] || echo '{"remote": []}' > "$CONFIG"
else
  found="$(discover_manifests)"
  count="$(printf '%s\n' "$found" | grep -c . || true)"

  if [ "$count" -eq 1 ]; then
    CONFIG="$found"
    echo "Discovered manifest: $CONFIG"
  elif [ "$count" -gt 1 ]; then
    echo "error: found $count candidate manifests — refusing to guess which one you meant:" >&2
    printf '%s\n' "$found" | sed 's/^/  /' >&2
    echo >&2
    echo "Pick one:  ./install.sh --config <path>" >&2
    exit 1
  else
    echo "error: no agent skill manifest found under \$HOME (searched to depth 4)." >&2
    echo >&2
    echo "Not guessing a location — writing to a path the runtime does not read would look like" >&2
    echo "success while doing nothing. Once your agent has created its manifest, re-run this." >&2
    echo >&2
    echo "Or:  ./install.sh --config <path>    write to a path you name" >&2
    echo "     ./install.sh --print            emit the entry to add by hand" >&2
    exit 1
  fi
fi

# Idempotently ensure the remote entry exists AND contains every derived skill.
# (A plain "already configured -> exit" would never pick up skills added later.)
CONFIG="$CONFIG" REMOTE_SOURCE="$REMOTE_SOURCE" REF="$REF" SKILLS_JSON="$SKILLS_JSON" \
python3 - <<'PY'
import json, os, sys

path = os.environ['CONFIG']
source = os.environ['REMOTE_SOURCE']
ref = os.environ['REF']
skills = [{'name': n} for n in json.loads(os.environ['SKILLS_JSON'])]

try:
    with open(path) as f:
        config = json.load(f)
except json.JSONDecodeError as e:
    sys.exit('error: %s is not valid JSON (%s). Refusing to overwrite it.' % (path, e))

if not isinstance(config, dict):
    sys.exit('error: %s does not contain a JSON object. Refusing to overwrite it.' % path)

remotes = config.setdefault('remote', [])
entry = next((r for r in remotes
              if r.get('source') == source and r.get('ref') == ref), None)

if entry is None:
    remotes.append({'source': source, 'ref': ref, 'skills': skills})
    print('Added skill-os remote with %d skills.' % len(skills))
else:
    have = {s.get('name') for s in entry.setdefault('skills', [])}
    added = [s for s in skills if s['name'] not in have]
    entry['skills'].extend(added)
    print('skill-os remote present; added %d missing skill(s): %s'
          % (len(added), [s['name'] for s in added] or 'none'))

with open(path, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
print('Wrote %s' % path)
PY

echo "Restart the agent to load the new skills."
