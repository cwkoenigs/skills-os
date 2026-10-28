# Session-end flush reminder hook

Purpose: make the flush step survive week three. The hook only *asks*; it never
opens a PR or MR itself.

## Behaviour

On session end (or before context compaction, if the platform exposes that event):

1. If `.ds/captures/` has any records not yet flushed (this skill's drafts and ds-next's), print:
   `so-capture: N unflushed capture(s) — <titles>. Run flush?`
2. Nothing else. No auto-flush, no network calls.

## Shape (platform-agnostic)

```sh
#!/usr/bin/env sh
# so-capture-remind.sh — session-end reminder
stage="${SO_CAPTURE_STAGE:-.ds/captures}"
[ -d "$stage" ] || exit 0
n=$(ls "$stage"/*.md 2>/dev/null | wc -l | tr -d ' ')      # flushed ones are in $stage/flushed/
[ "$n" -gt 0 ] || exit 0
echo "so-capture: $n unflushed capture(s):"
grep -h '^title:' "$stage"/*.md | sed 's/^title: /  - /'
echo "Run: flush"
```

Register it under the platform's session-end (Claude Code: `Stop` hook; Cortex Code:
its equivalent hook point) per skill-os platform-split conventions — keep the
script identical, vary only the registration.
