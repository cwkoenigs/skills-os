# CI templates

Thin per-provider configs for `so-init` Step 4 to generate. Every one of them does the same thing:
check out the repo and run `./tests/verify.sh`.

**Why they are this short.** `tests/verify.sh` is the single source of check logic. A provider config
that reimplements the checks gives each provider its own subtly different idea of "passing," and
they drift. If a check needs to change, it changes in `verify.sh` and every provider inherits it.
Never expand these templates with check logic.

**Requirements to state when generating:** `bash`, `git`, `python3`. Nothing else. No secrets, no
network access, no credentials — every check reads local files. If a generated config asks for a
secret, something is wrong.

---

## GitHub Actions — `.github/workflows/verify.yml`

```yaml
name: verify

on:
  push:
  pull_request:

jobs:
  verify:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./tests/verify.sh
```

`ubuntu-latest` already has bash, git, and python3. `actions/checkout@v4` is required — several
checks compare against tracked content.

---

## GitLab CI — `.gitlab-ci.yml`

```yaml
verify:
  image: python:3.12-slim
  before_script:
    - apt-get update -qq && apt-get install -y -qq git bash >/dev/null
  script:
    - ./tests/verify.sh
```

The slim image omits git and bash, hence `before_script`. On a runner image that already has them,
drop it.

---

## Bitbucket Pipelines — `bitbucket-pipelines.yml`

```yaml
image: python:3.12-slim

pipelines:
  default:
    - step:
        name: verify
        script:
          - apt-get update -qq && apt-get install -y -qq git bash >/dev/null
          - ./tests/verify.sh
```

---

## Local git hook — `.git/hooks/pre-commit`

For a repo with no remote CI, or as a faster first line of defence. Not a substitute for CI on a
shared repo: hooks are per-clone and not version-controlled, so a teammate's clone has none.

```bash
#!/usr/bin/env bash
set -e
./build.sh >/dev/null
git add -A -- '*/cadence-core.md' '*/references/*.md' '*/platform.example.md'
./tests/verify.sh
```

Install with `chmod +x .git/hooks/pre-commit`. Note it re-stages regenerated copies, so a stale
vendored file is fixed rather than merely reported.

---

## No CI

A valid outcome. If the project has no git host or the user declines, say so plainly and tell them
the manual command:

```bash
./tests/verify.sh
```

Record the decision — do not silently skip generating anything and leave the user assuming they are
covered.
