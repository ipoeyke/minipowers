# minipowers

A minimal fork of [obra/superpowers](https://github.com/obra/superpowers) for
Claude Code: the six skills that still earn their context window with today's
models, and nothing else. No hooks, no other-harness ports, no ceremony.

Forked from upstream **v6.1.1** (commit
[`d884ae0`](https://github.com/obra/superpowers/commit/d884ae04edebef577e82ff7c4e143debd0bbec99),
2026-07). Upstream history is preserved in this repo up to that commit.

Why each skill survived (and eight didn't): see [ANALYSIS.md](ANALYSIS.md).

## Skills

| Skill | What it does |
|---|---|
| **brainstorming** | Turn an ambiguous idea into an approved design spec through one-question-at-a-time dialogue, before any code. |
| **writing-plans** | Turn a spec into bite-sized tasks with exact file paths, interfaces, and test intent — pinned requirements, not pre-written code. |
| **subagent-driven-development** | Execute a plan with a fresh implementer subagent per task, an adversarial reviewer per task, and a whole-branch review at the end. File-based handoffs (`task-brief`, `review-package` scripts) keep the orchestrator's context small; a progress ledger survives compaction. |
| **test-driven-development** | Red-green-refactor with the load-bearing step spelled out: watch the test fail, for the right reason. Includes the debugging stop-rule (3 failed fixes = architectural problem). |
| **verification-before-completion** | No success claims without running the verification command in the same message. |
| **writing-skills** | TDD for process documentation: pressure-test a skill on subagents before trusting it. |

The flow: **brainstorming → writing-plans → subagent-driven-development**,
with TDD inside each task and verification before every completion claim.

## Install

From a local clone:

```
/plugin marketplace add /path/to/minipowers
/plugin install minipowers@minipowers-dev
```

Or straight from GitHub:

```
/plugin marketplace add ipoeyke/minipowers
/plugin install minipowers@minipowers-dev
```

There is no SessionStart hook — skills trigger through Claude Code's normal
description-based routing, or explicitly (`/minipowers:brainstorming`, etc.).

## What was cut from upstream

Eight skills (using-superpowers, executing-plans, dispatching-parallel-agents,
using-git-worktrees, finishing-a-development-branch, requesting-code-review,
receiving-code-review, systematic-debugging — the last three folded into the
keepers), the SessionStart hook, and all non-Claude-Code harness ports and
packaging. Rationale per skill: [ANALYSIS.md](ANALYSIS.md).

## Credit

All the good ideas are Jesse Vincent's ([obra/superpowers](https://github.com/obra/superpowers), MIT).
This fork subtracts; it doesn't add.
