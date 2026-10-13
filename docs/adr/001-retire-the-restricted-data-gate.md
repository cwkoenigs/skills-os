# ADR-001: Retire the restricted-data gate

## Status
Accepted

## Date
2026-09-25

## Context
The cadence skills carried a per-change data-classification question, an internal-only review
track, a corroboration step, and an AGENTS.md category block. All of it was a carry-over from a
project that handled regulated data. No current project does, and the question was being asked on
every change for no decision it could change. (Source: commits 7e7991c and cef5e29.)

## Options Considered
1. **Keep the gate but default it to "not restricted"** — still asked on every change, still a
   branch in every skill, and a default answer that nobody reads is a gate in name only.
2. **Retire the gate and keep one content rule** — chosen. Guidebook §1.1 and §2.2 are marked
   retired with their numbers kept so older citations resolve; the only surviving rule is §9.2,
   that a credential never enters a diff, a log or a review handoff, enforced by
   so-codex-review's silent secret scan.

## Decision
One review track: internal review plus external review at the G1, G2 and G3 gates, with the
developer confirming before each external call. so-codex-review accepts and ignores the old
`restricted` and `review_track` inputs from older callers. platform.md loses its
classification-tooling section and has six sections.

## Consequences
Positive: one fewer question per change, less branching in five skills, and emails, hostnames
and paths are treated as ordinary project content rather than redacted. Negative: a future
project that does handle regulated data must add its own controls in `shared/platform.md`
rather than inheriting a gate. Operational: vendored copies rebuilt by `./build.sh`.

## Validation
No skill asks the classification question, `./tests/verify.sh` passes with the rebuilt copies,
and a payload containing a credential is still refused by so-codex-review.

## Review Date
2027-03-25
