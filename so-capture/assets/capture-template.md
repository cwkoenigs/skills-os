---
# Capture record — one file per capture. Filename: YYYY-MM-DD-<slug>.md
id: <yyyymmdd-hhmm-slug>          # stable, generated once; never edited
type: <problem|discovery|decision|gotcha|question>
status: draft                     # draft → flushed (in a PR or MR) → published (merged)
title: <one line, ≤80 chars, states the thing not the topic>
author: <git user.name>
captured_at: <ISO-8601>
repo: <repo slug, from git remote — no hostnames>
ref: <branch@short-sha at time of capture>
tags: [<area>, <tech>, ...]       # e.g. [spcs, snowflake, gitlab-ci, uv]
related: []                       # ids of earlier captures, if known
---

## Summary
<2–4 sentences. What is true now that wasn't known before, or what is broken and how it presents. Written for a teammate with zero session context.>

## Evidence
<The minimum that lets someone trust or reproduce it: the error text, the query, the command, the diff hunk, a doc link. Fenced blocks. No secrets, no account identifiers, no internal hostnames — the skill scrubs, the reviewer confirms.>

## What was tried
<Only for problem/gotcha. Dead ends save the next person the most time. Bullet each attempt with why it didn't work.>

## Resolution / recommendation
<discovery/decision: the guidance. problem: the fix, or "unresolved — see Open".
gotcha: the rule of thumb. Make it actionable: "do X, not Y, because Z".>

## Open
<Unanswered questions, if any. Leave empty rather than inventing.>
