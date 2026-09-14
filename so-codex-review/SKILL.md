---
name: so-codex-review
description: Review a diff or selected code for actionable correctness issues, regressions, and missing validation.
---

# Code review

Establish the review scope and read enough surrounding code to understand the
changed behavior. Trace relevant callers, data flow, and existing tests.

Prioritize actionable defects introduced or exposed by the reviewed code. For
each finding, give a precise file location, triggering scenario, impact, and
supporting reasoning. Separate uncertain concerns from demonstrated issues.

If no actionable issues are found, say so and describe any material testing gaps.
