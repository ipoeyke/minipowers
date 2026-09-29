---
name: executing-specs
description: Use when executing an approved small-scope spec directly, without an implementation plan - produces a single commit at the end.
---

# Executing Specs

Execute an approved spec directly: implementer subagent(s), one whole-diff
review, a fix loop, verification, then a single squashed commit.

This is the light-tier path, reached via brainstorming's tier triage for
small, single-subsystem changes. The spec, including its Implementation
notes, is the whole brief: no plan, no task briefs, no per-task reviews, no
ledger, no kickoff docs commit.

Shared files live in the subagent-driven-development skill directory
(`../subagent-driven-development/` from this skill's directory), referenced
below as `SDD/`: `SDD/implementer-prompt.md`,
`SDD/code-reviewer.md`, and `SDD/scripts/`.

## 0. Entry Gate

Read the spec's header lines first:

- **Tier: light** - proceed.
- **Tier: heavy** - stop and invoke writing-plans instead.
- **No tier recorded** - apply brainstorming's tier-triage criteria, state
  your assessment, and get the user's confirmation. Any unresolved
  decision ("TBD", "implementation must confirm", an open interface) makes
  it heavy.

## 1. Setup

1. Require a clean tree (`git status --porcelain` empty); otherwise ask the
   user to commit or stash. A dirty base folds undispatched work into the
   squash.
2. Never start on main/master without explicit user consent.
3. Record the base SHA (`git rev-parse HEAD`).
4. Clear earlier runs' artifacts: `SDD/scripts/sdd-workspace --reset`.
5. Baseline: run each verification command the spec or project defines
   (tests, lint, type-check) once and record pass/fail with a one-line
   summary of each failure. Pass it into every implementer and fix
   dispatch: it tells them which failures predate them, and proves the
   toolchain resolves before any dispatch.

## 2. Implement

Dispatch implementers sequentially with `SDD/implementer-prompt.md`, using
its executing-specs values: the spec path as the brief, plus the baseline
and test seam, and `[TRAILER]` as the exact Co-Authored-By line from
your own session's attribution. When the Implementation notes need more than one dispatch,
summarize each earlier dispatch's outcome in the next one's context.
Handle statuses as in subagent-driven-development's Handling Implementer
Status.

After each dispatch, run the escalation check (below).

## 3. Review

1. Run the full suite and lint once at HEAD, output to
   `.minipowers/sdd/full-suite-<head7>.txt`.
2. Run `SDD/scripts/review-package BASE HEAD`.
3. Dispatch one reviewer with `SDD/code-reviewer.md` on the strongest
   available model (Fable if offered, else Opus): a one-line description,
   the spec as requirements, the package path, the full-suite output path,
   "none" for deferred Minors, and a findings file
   (`.minipowers/sdd/review-findings-BASE..HEAD.md`).

If the review ends without a report, read the findings file first and
re-dispatch only for what it does not cover, handing the file over to be
amended.

## 4. Fix Loop

For Critical or Important findings, dispatch one fix subagent (Sonnet)
with the findings file path, then regenerate the package and re-review.
Repeat until none are open.

## 5. Verify

Run minipowers:verification-before-completion. If HEAD is unchanged since
the pre-review full run, that output is the evidence; otherwise run the
suite again. Failures present in the baseline are reported, not blockers;
anything newly red blocks.

## 6. Squash

```
git reset --soft <base SHA>
git commit -m "<type>: <description>"
```

Stage the spec in this same commit. Conventional Commits subject, no body.

## 7. Wrap-up

On a branch, ask the user once: merge locally, push + PR, or leave as-is.

## Model Selection

Implementers and fix subagents run on Sonnet; if one reports BLOCKED on
reasoning depth, re-dispatch it on Opus. The reviewer runs on the
strongest available model. Always set the model explicitly.

## Escalation Check

After each dispatch, run `git diff --name-only <base SHA>..HEAD | wc -l`.
Stop if the count exceeds the spec's **Escalation threshold**, a dispatch
ran past ~30 minutes or reported ballooning scope, or an interface
ambiguity emerged that the spec did not anticipate.

Do not improvise a plan. Report what changed since the spec was written and
offer to route the remaining work through writing-plans and
subagent-driven-development. Do not squash first - the checkpoint commits
are what make the handoff clean.

## Never

- Proceed past the Entry Gate with a heavy or unconfirmed spec
- Dispatch implementers in parallel
- Run, or let any dispatch run, repo-wide format or lint autofix -
  path-scoped only
- Squash with open Critical or Important findings, an unresolved escalation,
  or before the verification gate
