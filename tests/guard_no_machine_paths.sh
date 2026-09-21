#!/usr/bin/env bash
# guard_no_machine_paths.sh — no machine-specific paths in shipped skill content.
#
# Skills install onto other people's machines. A hardcoded home directory ("/Users/alice/code")
# will not resolve for anyone else and can send the agent reading non-existent directories. Use
# $HOME, a leading ~/, or a <placeholder> instead.
#
# Scans tracked content under so-*/ and shared/. There is deliberately NO allowlist: an exception
# keyed to a specific file's specific lines is a deferred cleanup wearing a policy costume. If a
# match is legitimate, rewrite it as $HOME or a <placeholder>.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

# A machine home path: /Users/<name> or /home/<name>, where <name> is not a placeholder or var.
PATTERN='/(Users|home)/[A-Za-z0-9._-]+'
# Allowed immediately after /Users/ or /home/ : $VAR, <placeholder>, or ~
ALLOWED_NEXT='/(Users|home)/(\$|<|~)'

scan() {
  # $1 = file, prints "line:content" for each violation
  local f="$1"
  grep -nE "$PATTERN" "$f" 2>/dev/null | grep -vE "$ALLOWED_NEXT" || true
}

# --- self-test: prove the guard actually catches and allows what it claims ---------------------
selftest="$(mktemp)"
trap 'rm -f "$selftest"' EXIT
cat > "$selftest" <<'EOT'
bad: /Users/alice/code/project
bad: /home/bob/scripts
ok:  $HOME/.config/skill-os
ok:  ~/.ssh/config
ok:  /Users/<your-name>/code
ok:  /Users/$USER/code
ok:  /opt/homebrew/bin
EOT
got="$(scan "$selftest" | wc -l | tr -d ' ')"
if [ "$got" != "2" ]; then
  echo "GUARD FAIL: self-test expected 2 violations, got $got — the pattern is broken" >&2
  scan "$selftest" >&2
  exit 1
fi
echo "PASS: self-test (real paths caught; \$HOME / ~ / <placeholder> / \$USER allowed)"

# --- scan tracked skill + shared content ------------------------------------------------------
violations=0
while IFS= read -r file; do
  [ -f "$file" ] || continue
  while IFS= read -r hit; do
    [ -n "$hit" ] || continue
    echo "VIOLATION: $file:$hit"
    violations=$((violations + 1))
  done < <(scan "$file")
done < <(git ls-files 'so-*' 'shared/*')

if [ "$violations" -ne 0 ]; then
  echo
  echo "GUARD FAIL: $violations machine-path violation(s) in tracked skill content." >&2
  echo "Rewrite as \$HOME, a leading ~/, or a <placeholder>." >&2
  exit 1
fi

echo "GUARD OK: no machine-specific paths in tracked so-*/ or shared/ content"
